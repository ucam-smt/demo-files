
.. _adding_components-label:

Tutorial: Adding new components
===============================

We welcome contributions to SGNMT. This tutorial will help you get started with writing new components.
This tutorial assumes that you have read the :ref:`tutorial-label` page and are already familiar with the basic 
concepts of *predictors* and *decoders*. You should also be comfortable with coding in Python.

Writing decoders
-----------------

This section explains how to write decoders (search strategies) that are decoupled from predictors, ie. work with any
predictor constellation. This tutorial walks you through implementing a new *simplebeam* decoder, which will be a simplified 
version of the `standard beam search implementation <https://github.com/ucam-smt/sgnmt/blob/master/cam/sgnmt/decoding/beam.py>`_ in SGNMT.

The first step is to make SGNMT aware of the new decoder. Find the ``create_decoder()`` factory method in *cam/sgnmt/decode_utils.py*.
This method instantiates decoders based on the ``--decoder`` argument. Add the following code to the if-structure:

.. code-block:: python

    ...
    elif args.decoder == "simplebeam":
            decoder = SimpleBeamDecoder(args)
    ...

Import ``SimpleBeamDecoder`` at the begin of *decode_utils.py*.

.. code-block:: python

    from cam.sgnmt.decoding.simplebeam import SimpleBeamDecoder

Finally, you need to update the specification of ``--decoder`` in the command-line argument parser. Open *cam/sgnmt/ui.py*
and find the following snippet in the ``get_parser()`` method:

.. code-block:: python

    group.add_argument("--decoder", default="beam",
                            choices=['greedy',
                                     'beam',
                                     'multisegbeam',
                                     ...

Add *simplebeam* to the list of choices and save the file.

Create a new file *cam/sgnmt/decoding/simplebeam.py* and open it in your favorite text editor. This is where we will implement
our new decoder. Copy the following Decoder stub implementation to *simplebeam.py*:

.. code-block:: python

    import copy
    from cam.sgnmt import utils
    from cam.sgnmt.decoding.core import Decoder, PartialHypothesis

    class SimpleBeamDecoder(Decoder):

        def decode(self, src_sentence):
            print("SimpleBeam source sentence: %s" % src_sentence)

This implementation does not do much yet. In fact, it will result in an error since ``decode()`` is expected to return translation
hypotheses. However, you can still test if your code is reached by activating the *simplebeam* decoder in the  
:ref:`tutorial-label` environment::

    $ python $SGNMT/decode.py --decoder simplebeam --predictors nmt --config_file tut.ini
    ...
    SimpleBeam source sentence: [1543, 7, 1491, 1359, 1532, 692, 9, 6173]
    2017-10-14 12:57:03,171 ERROR: An unexpected <type 'exceptions.TypeError'> error has occurred at sentence id 1: 'NoneType' object is not iterable, Stack trace: Traceback (most recent call last):
      File "/home/mifs/fs439/bin/sgnmt-tut/cam/sgnmt/decode_utils.py", line 651, in do_decode
          for hypo in decoder.decode(utils.apply_src_wmap(src))
          TypeError: 'NoneType' object is not iterable

As expected, SGNMT crashes because of the lack of a return value, but the print statement in your ``decode()`` method is executed.
Next we would like to access certain command-line arguments, for example the ``--beam`` option for configuring the beam size. All
options can be accessed via ``decoder_args`` in the constructor. Add the following constructor to ``SimpleBeamDecoder``:

.. code-block:: python

    def __init__(self, decoder_args):
        super(SimpleBeamDecoder, self).__init__(decoder_args)
        self.beam_size = decoder_args.beam

We will now focus on implementing the ``decode()`` method in our ``SimpleBeamDecoder``. The general idea is to maintain a list
of *beam_size* (partial) hypotheses ``hypos``, sorted from best to worst. We initialize ``hypos`` with the empty translation
prefix and the initial predictor states. We keep doing beam search iterations until the best hypothesis in ``hypos`` ends with 
the end-of-sentence symbol:

.. code-block:: python

    def decode(self, src_sentence):
        self.initialize_predictors(src_sentence)
        hypos = [PartialHypothesis(self.get_predictor_states())]
        while hypos[0].get_last_word() != utils.EOS_ID:
            next_hypos = []
            for hypo in hypos:
                next_hypos.extend(self._expand_hypo(hypo))
            next_hypos.sort(key=lambda h: -h.score)
            hypos = next_hypos[:self.beam_size]
        return [hypos[0].generate_full_hypothesis()]

The core of the algorithm is the ``_expand_hypo()`` method which still needs to be implemented. Expanding a partial hypothesis 
``hypo`` involves the following steps:

  * Load the predictor states from ``hypo``.
  * Consume the last word in ``hypo`` if necessary.
  * Call ``apply_predictors()`` to get the scores for the next time step.
  * Expand ``hypo`` with the best ``beam_size`` scores and the updated predictor states.

.. code-block:: python

    def _expand_hypo(self, hypo):
        if hypo.get_last_word() == utils.EOS_ID:
            return [hypo]
        self.set_predictor_states(copy.deepcopy(hypo.predictor_states))
        if not hypo.word_to_consume is None: # Consume if cheap expand
            self.consume(hypo.word_to_consume)
            hypo.word_to_consume = None
        posterior, score_breakdown = self.apply_predictors()
        hypo.predictor_states = self.get_predictor_states()
        top = utils.argmax_n(posterior, self.beam_size)
        return [hypo.cheap_expand(
                            trgt_word,
                            posterior[trgt_word],
                            score_breakdown[trgt_word]) for trgt_word in top]

Verify that your new decoder works as expected::

    $ python $SGNMT/decode.py --decoder simplebeam --predictors nmt --config_file tut.ini
    (...)
    2017-10-14 13:40:00,782 INFO: Decoded (ID: 1): 1511 7 1422 894 30 8 10453
    2017-10-14 13:40:00,782 INFO: Stats (ID: 1): score=-3.700894 num_expansions=85 time=28.04

You should obtain the same translation and the same score as using the standard beam search implementation with ``--decoder beam``.

Writing predictors
------------------

The first decision to make when implementing a new predictor is about the structure of its state. Consider the following two code
examples:


.. code-block:: python

    predictor.predict_next()
    state = predictor.get_state()
    arbitrarySequenceOfPredictNextAndConsumeCalls()
    predictor.set_state(state)
    predictor.consume(word)

.. code-block:: python

    predictor.consume(word)
    state = predictor.get_state()
    arbitrarySequenceOfPredictNextAndConsumeCalls()
    predictor.set_state(state)
    predictor.predict_next()

The predictor state must contain enough information such that the last lines in the above examples always exhibit the same
behavior, independently of how many (if any) function calls are made in ``arbitrarySequenceOfPredictNextAndConsumeCalls()``.
The next central questions are:

  * How to initialize the predictor state given the source sentence (``initialize()``)?
  * How to compute the posterior for the next target position given the state (``predict_next()``)?
  * How to update the predictor state when consuming a target token (``consume()``)?

Let's say we want to write a predictor which enforces that the target sentence length is always equal to the source
sentence length. Open *cam/sgnmt/decode_utils.py*, find the ``add_predictors()`` method and add the following piece of
code to the main if-structure:

.. code-block:: python

    ...
    elif pred == "eqlen":
        p = EqualLengthPredictor()
    ...
                            
Import the new ``EqualLengthPredictor`` at the begin of *decode_utils.py*

.. code-block:: python

    from cam.sgnmt.predictors.equal_length import EqualLengthPredictor

We will implement the new predictor in a new file called *cam/sgnmt/predictors/equal_length.py*. Here is the complete
implementation:


.. code-block:: python

    from cam.sgnmt.predictors.core import Predictor
    from cam.sgnmt import utils
    
    class EqualLengthPredictor(Predictor):
    
        def get_unk_probability(self, posterior):
            if self.n_consumed == self.src_length:
                return utils.NEG_INF
            return 0.0

        def predict_next(self):
            if self.n_consumed == self.src_length:
                return {utils.EOS_ID : 0.0}
            return {utils.EOS_ID : utils.NEG_INF}

        def initialize(self, src_sentence):
            self.src_length = len(src_sentence)
            self.n_consumed = 0

        def consume(self, word):
            self.n_consumed += 1

        def get_state(self):
            return self.n_consumed

        def set_state(self, state):
            self.n_consumed = state


The state of the predictor is the number of target tokens consumed so far (``self.n_consumed``). ``predict_next()``
sets the score of the end-of-sentence symbol to 0.0 (optimal score) if this matches the required length ``self.src_length``,
and to negative infinity otherwise, preventing the end-of-sentence symbol if this condition is not met. Scores for all
tokens which are not in the dictionary returned by ``predict_next()`` are defined via the ``get_unk_probability()`` method.
We assign negative infinity to all tokens besides end-of-sentence if the hypothesis has the right length, and an optimal
score of 0.0 otherwise.


Verify that your new predictor works by trying the following command in the :ref:`tutorial-label` setup::

    $ python $SGNMT/decode.py --predictors eqlen,nmt --config_file tut.ini
    2017-10-15 14:13:31,049 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
    2017-10-15 14:13:57,378 INFO: Decoded (ID: 1): 1511 7 1422 0 894 30 8 10453
    2017-10-15 14:13:57,378 INFO: Stats (ID: 1): score=-4.779791 num_expansions=88 time=26.33
    2017-10-15 14:13:57,378 INFO: Decoding finished. Time: 26.33

Both source and target sentence consist of 8 tokens.
