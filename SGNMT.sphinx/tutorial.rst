
.. _tutorial-label:

Tutorial
========

.. warning:: 

      This tutorial is currently under development!

This tutorial describes common use cases for SGNMT. Please
download the `WMT'15 tutorial data <https://www.repository.cam.ac.uk/#will-be-available-soon>`_ archive
and extract it::

  $ wget http://example.org/
  $ tar xzf tutorial-ende-wmt15.tar.gz
  $ cd tutorial-ende-wmt15

This tarball contains NMT model files and translation lattices for replicating some of our results on the 
WMT'15 test set (English-German) in our `ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_. The
directory structure is as follows:

* *./data/* contains the source and target sentences for news-test2015 and word maps.
* *./train/* contains the NMT model file ``params.npz``.
* *./train2/* contains a second NMT model for ensembling.
* *./lm/* contains language model files
* *./lats/* contains the Hiero translation lattices.
* *./scripts/* contains helper scripts for creating lattice directories or applying word maps.

This structure is indended to be used as starting point for your own experiments.

The `ucam-smt tutorial <http://ucam-smt.github.io/tutorial/nmt.html>`_ explains how to generate translation lattices
for SGNMT in general.

For this tutorial, we assume that you set the ``$SGNMT`` environment variable to the location of your SGNMT installation::

  $ export SGNMT=/path/to/sgnmt


Pure NMT decoding (single)
----------------------------------------

Start the NMT decoder with the following command::

  $ python $SGNMT/decode.py --predictors nmt --src_test data/test15.ids.en --range 1:1 --src_vocab_size 50003 --trg_vocab_size 50003
  2016-05-19 12:59:07,348 INFO: Creating theano variables
  2016-05-19 12:59:07,350 INFO: Building RNN encoder-decoder
  (...)
  2016-05-19 12:59:21,492 INFO: Loading the model from ./train/params.npz
  (...)
  2016-05-19 12:59:28,028 INFO: Start time: 1463659168.03
  2016-05-19 12:59:28,028 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 12:59:59,183 INFO: Decoded (ID: 1): 1511 7 1422 894 30 8 10453
  2016-05-19 12:59:59,183 INFO: Stats (ID: 1): score=-3.700894 num_expansions=85 time=31.15
  2016-05-19 12:59:59,183 INFO: Decoding finished. Time: 31.16

The ``--predictors nmt`` argument tells SGNMT to use the NMT scoring module. The ``--src_test`` option defines the location of the
source sentences to translate (words are represented by IDs), and ``--range 1:1`` limits the decoding to the first sentence. SGNMT will
search for NMT model files in the default location *./train/*. The arguments ``src_vocab_size`` and ``--trg_vocab_size`` specify that the 
NMT model has been trained with vocabulary sizes of 50003. Since we will use the last four options throughout this tutorial, we load them
from a configuration file instead of adding them separately::

  $ cat tut.ini
  src_test: data/test15.ids.en
  range: '1:1'
  src_vocab_size: 50003
  trg_vocab_size: 50003
  $ python $SGNMT/decode.py --predictors nmt --config_file tut.ini
  (...)
  2016-05-19 12:59:59,183 INFO: Decoded (ID: 1): 1511 7 1422 894 30 8 10453


You can look at our first translation by using the *apply_wmap.py* script::

  $ echo '1511 7 1422 894 30 8 10453' | python scripts/apply_wmap.py -m data/wmap.test15.de -d i2s
  Indien und Japan treffen sich in Tokio

For single NMT decoding, you have the option to use an optimized version of the beam decoder::

  $ python $SGNMT/decode.py --decoder vanilla --config_file tut.ini
  (...)
  2016-05-19 13:14:27,040 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 13:14:34,009 INFO: Decoded (ID: 1): 1511 7 1422 894 30 8 10453
  2016-05-19 13:14:34,009 INFO: Stats (ID: 1): score=-3.700894 num_expansions=120 time=6.97
  2016-05-19 13:14:34,009 INFO: Decoding finished. Time: 6.97

However, this decoder bypasses the predictor framework. Therefore, you cannot use it in combination with other
predictors, e.g. for lattice rescoring or ensembled NMT decoding.


Ensemble NMT decoding
----------------------------------------

NMT ensembling can be realized by simply adding a second NMT predictor. However, we need to override the NMT configuration
for the second NMT predictor to load a different NMT model. We can use ``--nmt_config`` for this. Therefore,
to override the ``saveto`` options which stores the NMT training directory, we add ``--nmt_config saveto=train2``::

  $ python $SGNMT/decode.py --predictors nmt,nmt --nmt_config2 saveto=train2 --config_file tut.ini
  (...)
  2016-05-19 13:24:36,060 INFO: Loading the model from ./train/params.npz
  (...)
  2016-05-19 13:24:56,942 INFO: Loading the model from train2/params.npz
  (...)
  2016-05-19 13:25:10,937 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 13:25:56,787 INFO: Decoded (ID: 1): 1511 7 1422 894 30 8 10453
  2016-05-19 13:25:56,787 INFO: Stats (ID: 1): score=-6.195214 num_expansions=83 time=45.85
  2016-05-19 13:25:56,787 INFO: Decoding finished. Time: 45.87

The first NMT predictor still uses the default NMT training directory location *./train/*, but the second NMT instance loads the
NMT model from *train2/params.npz*.

Lattice rescoring with NMT (SGNMT)
----------------------------------------

For restricting NMT to a translation lattice, we need the *fst* predictor::

  $ python $SGNMT/decode.py --predictors nmt,fst --fst_path lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:37:29,601 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:37:36,437 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:37:36,437 INFO: Stats (ID: 1): score=-4.779791 num_expansions=64 time=6.84
  2016-05-19 15:37:36,437 INFO: Decoding finished. Time: 6.84

  $ echo '1511 7 1422 84829 894 30 8 10453' | python scripts/apply_wmap.py -m data/wmap.test15.de -d i2s
  Indien und Japan Premierministern treffen sich in Tokio


This command loads the determinised lattice *./lats/1.fst* from the file system and runs the NMT beam search decoder on it. For non-deterministic lattices use
the *nfst* predictor instead. Per default, SGNMT ignores the scores in the translation lattices. To change this, use ``--use_fst_weights``::

  $ python $SGNMT/decode.py --predictors nmt,fst --fst_path lats/%d.fst --use_fst_weights true --predictor_weights 2.7,24.4 --config_file tut.ini
  (...)
  2016-05-19 15:41:19,878 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:41:28,228 INFO: Decoded (ID: 1): 1511 7 1422 3278 7 2830 894 30 8 10453
  2016-05-19 15:41:28,229 INFO: Stats (ID: 1): score=-50.385922 num_expansions=72 time=8.35
  2016-05-19 15:41:28,229 INFO: Decoding finished. Time: 8.35

  $ echo '1511 7 1422 3278 7 2830 894 30 8 10453' | python scripts/apply_wmap.py -m data/wmap.test15.de -d i2s   
  Indien und Japan Staats- und Regierungschefs treffen sich in Tokio

This command uses ``--predictor_weights`` to weight the NMT scores against the lattice scores (corresponds to the lambdas in the `ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_).

So far, we applied beam decoding as search strategy. However, the beam decoder introduces search errors. SGNMT supports a variety of decoding strategies such 
as greedy, beam, depth-first search, and A* search. To do an exhaustive search over the lattice, use the depth-first search decoder::

  $ python $SGNMT/decode.py --decoder dfs --predictors nmt,fst --fst_path lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:43:33,713 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:43:35,926 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:43:35,926 INFO: Stats (ID: 1): score=-4.779791 num_expansions=17 time=2.21
  2016-05-19 15:43:35,926 INFO: Decoding finished. Time: 2.21

In this case, the exact decoding was very fast because DFS automatically enables admissible pruning of branches in the search tree with accumulated scores
worse than the current best hypothesis. If we disable this feature with ``--early_stopping false``, we see that SGNMT finds the same hypothesis but with 
much more node expansions::

  $ python $SGNMT/decode.py --decoder dfs --early_stopping false --predictors nmt,fst --fst_path lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:44:28,765 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:45:12,650 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:45:12,650 INFO: Stats (ID: 1): score=-4.779791 num_expansions=334 time=43.88
  2016-05-19 15:45:12,650 INFO: Decoding finished. Time: 43.89


Working with language models
----------------------------------------

Language model scores can be added to the lattices before passing them through to SGNMT. This is the approach we took in the
`ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_. Alternatively, the nplm predictor can be used directly in SGNMT. A German NPLM model file
can be found in *./lm/nplm*. However, this model has been trained with a different word map. Therefore, we add the *idxmap* wrapper predictor
to the *nplm* predictor. This wrapper translates between word indices used by SGNMT, and indices used by the NPLM predictor. The mapping between
indices is defined with the ``--src_idxmap`` and ``--trg_idxmap`` arguments::

  $ python $SGNMT/decode.py --predictors nmt,fst,idxmap_nplm --fst_path lats/%d.fst --nplm_path lm/nplm --src_idxmap data/idxmap.nplm.en --trg_idxmap data/idxmap.nplm.de --config_file tut.ini
  2016-05-19 16:24:47,811 INFO: Start time: 1463671487.81
  2016-05-19 16:24:47,811 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 16:24:54,768 INFO: Decoded (ID: 1): 1511 7 1422 84829 8 10453
  2016-05-19 16:24:54,768 INFO: Stats (ID: 1): score=-43.008210 num_expansions=56 time=6.96
  2016-05-19 16:24:54,768 INFO: Decoding finished. Time: 6.96

  echo '1511 7 1422 84829 8 10453' | python scripts/apply_wmap.py -m data/wmap.test15.de -d i2s 
  Indien und Japan Premierministern in Tokio

This results in a translation which is too short, because the language model prefers short hypotheses. To counteract that, adjust the weight between NMT and LM with ``--predictor_weights``,
or add a word count feature with the *wc* predictor. The *srilm* predictor supports loading Kneser-Ney language models in ARPA format.

Creating output files
----------------------------------------

TODO

Distributed decoding using the Grid Engine
-------------------------------------------

TODO
