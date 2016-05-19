
Frequently Asked Questions
===========================

.. note:: 

      If you don't find an answer here, check out the `issue tracker on Github <http://github.com/ucam-smt/sgnmt/issues>`_.


'Dimension mismatch' warnings with neural models
-------------------------------------------------

This warning often indicates that the NMT model configuration does not match the training configuration of the
loaded NMT model, e.g. because the model has been trained with a different vocabulary size. Double-check the NMT
configuration parameters, especially ``--src_vocab_size``, ``--trg_vocab_size``, ``--enc_nhids``, ``--enc_embed``,
``--dec_nhids``, and ``--dec_embed``.



No such file or directory: 'test_en'
---------------------------------------------

Per default, SGNMT tries to read the source sentences to translate from a file called 'test_en'. You should
specify the path to the source sentences with ``--src_test``, or use the input methods 'stdin' or 'shell'
for interactive usage.

Theano error: UnusedInputError
-------------------------------------------------------

This is blocks related and has been discussed `here <https://github.com/mila-udem/blocks-examples/issues/58>`_. The solution is
to add ``on_unused_input='ignore'`` to your ``THEANO_FLAGS``::

  $ export THEANO_FLAGS="on_unused_input='ignore'"


KeyError when using NPLM
-----------------------------

If you are using nplm 0.3 there might be a bug in the Python module that prevents the nplm predictor to read model files.
Try to replace *nplm.py* in the *python/* directory of your NPLM installation with `this file <http:///ucam-smt.io/sgnmt/html/_static/nplm.py>`_.
