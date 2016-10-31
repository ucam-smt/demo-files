
.. _tutorial-label:

Tutorial
========

This tutorial describes common use cases for SGNMT. We will use the Blocks NMT implementation (not TensorFlow) in this
tutorial. Please make sure that you have installed (at least) OpenFST and Blocks correctly as described 
on the :ref:`setup-label` page.

The tutorial data is available under the following DOI:

http://dx.doi.org/10.17863/CAM.282

Please download the archive and extract it::

  $ tar xzf tutorial-ende-wmt15.tar.gz
  $ cd tutorial-ende-wmt15

This tarball contains NMT model files and translation lattices for replicating some of our results on the 
WMT'15 test set (English-German) in our `ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_. The
directory structure is as follows:

* *./data/* contains the source and target sentences for news-test2015 and word maps.
* *./train/* contains the NMT model file ``params.npz``.
* *./train2/* contains a second NMT model for ensembling.
* *./lm/* contains language model files
* *./hiero/lats/* contains the Hiero translation lattices.
* *./hiero/100best.txt* is an n-best list generated with Hiero.
* *./scripts/* contains helper scripts for creating lattice directories or applying word maps.

This structure is indended to be used as starting point for your own experiments.

The `ucam-smt tutorial <http://ucam-smt.github.io/tutorial/nmt.html>`_ explains how to generate translation lattices
for SGNMT in general.

For this tutorial, we assume that you set the ``$SGNMT`` environment variable to the location of your SGNMT installation::

  $ export SGNMT=/path/to/sgnmt

Introduction
----------------------------------------

The two central concepts in SGNMT are *predictors* and *decoders*. *Predictors* are scoring modules which define scores over
the target language vocabulary given the current internal predictor state, the history, the source sentence, and external side information. 
Predictors have a strict left-to-right semantic. They can represent translation models like NMT or language models. In a more general sense, 
translation lattices or n-best lists can also be represented in this framework. Predictors can be combined with other predictors to form
complex decoding tasks. 

*Decoders* are search strategies which traverse the space spanned by the predictors. SGNMT provides implementations of common
search tree traversal algorithms like beam search. Since decoders differ in runtime complexity and the kind of search errors they make,
different decoders are appropriate for different predictor constellations.

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
search for NMT model files in the default location *./train/*. The arguments ``--src_vocab_size`` and ``--trg_vocab_size`` specify that the 
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

For single NMT decoding, you have the option to use an optimised version of the beam decoder::

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

NMT ensembling can be done by simply adding a second NMT predictor. However, we need to override the NMT configuration
for the second NMT predictor to load a different NMT model. We can use ``--nmt_config2`` for this. Therefore,
to override the ``saveto`` options which stores the NMT training directory, we add ``--nmt_config2 saveto=train2``::

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

Lattice rescoring (SGNMT)
----------------------------------------

For restricting NMT to a translation lattice, we need the *fst* predictor::

  $ python $SGNMT/decode.py --predictors nmt,fst --fst_path hiero/lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:37:29,601 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:37:36,437 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:37:36,437 INFO: Stats (ID: 1): score=-4.779791 num_expansions=64 time=6.84
  2016-05-19 15:37:36,437 INFO: Decoding finished. Time: 6.84

  $ echo '1511 7 1422 84829 894 30 8 10453' | python scripts/apply_wmap.py -m data/wmap.test15.de -d i2s
  Indien und Japan Premierministern treffen sich in Tokio


This command loads the determinised lattice *./hiero/lats/1.fst* from the file system and runs the NMT beam search decoder on it. For non-deterministic lattices use
the *nfst* predictor instead. Per default, SGNMT ignores the scores in the translation lattices. To change this, use ``--use_fst_weights``::

  $ python $SGNMT/decode.py --predictors nmt,fst --fst_path hiero/lats/%d.fst --use_fst_weights true --predictor_weights 2.7,24.4 --config_file tut.ini
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

  $ python $SGNMT/decode.py --decoder dfs --predictors nmt,fst --fst_path hiero/lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:43:33,713 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:43:35,926 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:43:35,926 INFO: Stats (ID: 1): score=-4.779791 num_expansions=17 time=2.21
  2016-05-19 15:43:35,926 INFO: Decoding finished. Time: 2.21

In this case, the exact decoding was very fast because DFS automatically enables admissible pruning of branches in the search tree with accumulated scores
worse than the current best hypothesis. If we disable this feature with ``--early_stopping false``, we see that SGNMT finds the same hypothesis but with 
much more node expansions::

  $ python $SGNMT/decode.py --decoder dfs --early_stopping false --predictors nmt,fst --fst_path hiero/lats/%d.fst --config_file tut.ini
  (...)
  2016-05-19 15:44:28,765 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 15:45:12,650 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-19 15:45:12,650 INFO: Stats (ID: 1): score=-4.779791 num_expansions=334 time=43.88
  2016-05-19 15:45:12,650 INFO: Decoding finished. Time: 43.89

Informed search is implemented by the *astar* search strategy::

  $ python $SGNMT/decode.py --decoder astar --heuristics predictor --predictors nmt,fst --fst_path hiero/lats/%d.fst --use_fst_weights true --predictor_weights 2.7,24.4 --config_file tut.ini
  (...)
  2016-05-19 18:28:05,618 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-19 18:28:06,897 INFO: Decoded (ID: 1): 1511 7 1422 3278 7 2830 894 30 8 10453
  2016-05-19 18:28:06,898 INFO: Stats (ID: 1): score=-50.385922 num_expansions=11 time=1.28
  2016-05-19 18:28:06,898 INFO: Decoding finished. Time: 1.28

The option ``--heuristics predictor`` enables the predictor specific heuristics. In this example, this uses the shortest distances in the lattice as 
future cost estimates. This is a very weak heuristic as the *fst* predictor has a small weight, but it already speeds up decoding. Alternatively,
``--heuristics greedy`` performs greedy decoding with all predictors to estimate future cost (expensive but more accurate).


N-best list rescoring
----------------------------------------

The *forced* predictor implements single best rescoring (i.e. forced decoding). The ``--trg_test`` option needs to point to a plain text file with
the reference sentences::

  $ python $SGNMT/decode.py --predictors nmt,forced --trg_test data/test15.ids.de --config_file tut.ini
  (...)
  2016-05-20 10:21:07,916 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-20 10:21:09,200 INFO: Decoded (ID: 1): 5 3316 7930 7 7312 9864 30 8 10453 4
  2016-05-20 10:21:09,200 INFO: Stats (ID: 1): score=-23.736977 num_expansions=11 time=1.28
  2016-05-20 10:21:09,200 INFO: Decoding finished. Time: 1.28

For NMT n-best list rescoring, use the *forcedlst* predictor::

  $ python $SGNMT/decode.py --predictors nmt,forcedlst --decoder dfs --trg_test hiero/100best.txt --config_file tut.ini
  (...)
  2016-05-20 10:46:12,884 INFO: Next sentence (ID: 1): 1543 7 1491 1359 1532 692 9 6173
  2016-05-20 10:46:15,049 INFO: Decoded (ID: 1): 1511 7 1422 84829 894 30 8 10453
  2016-05-20 10:46:15,049 INFO: Stats (ID: 1): score=-4.779791 num_expansions=17 time=2.17
  2016-05-20 10:46:15,049 INFO: Decoding finished. Time: 2.17


The n-best list needs to be stored in `Moses format <http://www.statmt.org/moses/?n=Advanced.Search#ntoc1>`_. The *dfs* decoder efficiently
traverses the search space spanned by the n-best list by reusing predictor states for the same histories. If you are interested in rescoring 
the full n-best list and not only in the single best translation, use ``--early_stopping false``. In order to use the scores provided in the 
n-best list, add ``--use_nbest_weights true``.


Working with language models
----------------------------------------

Language model scores can be added to the lattices before passing them through to SGNMT. This is the approach we took in the
`ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_. Alternatively, the nplm predictor can be used directly in SGNMT for incorporating a
feedforward neural language model trained with `NPLM <http://nlg.isi.edu/software/nplm/>`_. A German NPLM model file
can be found in *./lm/nplm*. However, this model has been trained with a different word map. Therefore, we add the *idxmap* wrapper predictor
to the *nplm* predictor. This wrapper translates between word indices used by SGNMT, and indices used by the NPLM predictor. The mapping between
indices is defined with the ``--src_idxmap`` and ``--trg_idxmap`` arguments::

  $ python $SGNMT/decode.py --predictors nmt,fst,idxmap_nplm --fst_path hiero/lats/%d.fst --nplm_path lm/nplm --src_idxmap data/idxmap.nplm.en --trg_idxmap data/idxmap.nplm.de --config_file tut.ini
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

SGNMT supports four different output formats:

* *text*: Plain text file with the translations
* *nbest*: n-best list in 
* *sfst*: OpenFST translation lattices with standard arcs
* *fst*: OpenFST translation lattices with sparse tuple arcs

They can be activated with ``--outputs``. For example, this adds NMT scores to the Hiero n-best list *hiero/100best.txt*::

  $ python $SGNMT/decode.py --outputs text,nbest --predictors nmt,forcedlst --use_nbest_weights true --trg_test hiero/100best.txt --decoder dfs --early_stopping false --config_file tut.ini
  (...)
  $ head sgnmt-out.*
  ==> sgnmt-out.nbest <==
  0 ||| 1511 7 1422 6284 894 30 8 10453 ||| nmt= -5.695894 forcedlst= 10.681800 ||| 4.985906
  0 ||| 1511 7 1422 3316 894 30 8 10453 ||| nmt= -5.125271 forcedlst= 7.244780 ||| 2.119509
  0 ||| 1511 7 1422 6284 894 8 10453 ||| nmt= -7.310516 forcedlst= 9.359490 ||| 2.048974
  0 ||| 1511 7 1422 84829 894 30 8 10453 ||| nmt= -4.779791 forcedlst= 6.022160 ||| 1.242369
  0 ||| 1511 7 1422 13997 2153 894 30 8 10453 ||| nmt= -9.046590 forcedlst= 9.643540 ||| 0.596950
  0 ||| 1511 7 1422 3278 7 2830 894 30 8 10453 ||| nmt= -11.577704 forcedlst= 11.586500 ||| 0.008796
  0 ||| 1511 7 1422 3316 894 8 10453 ||| nmt= -6.950797 forcedlst= 6.573870 ||| -0.376927
  0 ||| 1511 7 1422 84829 894 8 10453 ||| nmt= -6.364513 forcedlst= 5.350270 ||| -1.014243
  0 ||| 1511 7 1422 2830 894 30 8 10453 ||| nmt= -8.984533 forcedlst= 7.901030 ||| -1.083503
  0 ||| 1511 7 7312 6284 894 30 8 10453 ||| nmt= -7.913851 forcedlst= 5.823900 ||| -2.089951

  ==> sgnmt-out.text <==
  1511 7 1422 6284 894 30 8 10453

The default output path is *sgnmt-out.%s* (can be changed with ``--output_path``). The generated n-best file *sgnmt-out.nbest* does not only show
the combined score, but also the separated predictor scores. In this case, *nmt=* contains the NMT log-likelihood, and *forcedlst=* corresponds
to the hypothesis score in the Hiero n-best list *hiero/100best.txt*.

Simple NMT translation lattices can be generated with the *sfst* output format::

  $ python $SGNMT/decode.py --outputs sfst --predictors nmt --config_file tut.ini
  (...)
  $ fstprint sgnmt-out.sfst/1.fst | head
  0 1 1 1 3.70089412
  0 10  1 1 4.99342918
  0 18  1 1 5.3186779
  0 26  1 1 5.67907906
  1 2 1511  1511
  2 3 7 7
  3 4 1422  1422
  4 5 894 894
  5 6 30  30
  6 7 8 8

If you wish to keep predictor scores separated in the generated lattices, use the *fst* output format to create lattices with 
`sparse tuple arcs <http://ucam-smt.github.io/tutorial/basictrans.html#lmert_veclats_tst>`_.
You'll need to `install HiFST <http://ucam-smt.github.io/tutorial/build.html>`_ to enable support for the tropicalsparsetuple arc type::

  $ python $SGNMT/decode.py --outputs fst --predictors nmt,fst --fst_path hiero/lats/%d.fst --use_fst_weights true --predictor_weights 2.7,24.4 --config_file tut.ini
  (...)
  $ TUPLEARC_WEIGHT_VECTOR=2.7,24.4 fstshortestpath sgnmt-out.fst/1.fst | fsttopsort | fstprint
  0 1 1 1
  1 2 1511  1511  0,1,0.420832008,2,0.00846654177
  2 3 7 7 0,1,0.129989997
  3 4 1422  1422  0,1,0.0673521981,2,0.00468987226
  4 5 3278  3278  0,1,9.95738029,2,0.680079401
  5 6 7 7 0,1,0.0128448997
  6 7 2830  2830  0,1,0.0604516007
  7 8 894 894 0,1,0.287970006,2,0.0195894614
  8 9 30  30  0,1,0.173721001,2,0.0528452434
  9 10  8 8 0,1,0.354806006,2,0.000487923622
  10  11  10453 10453 0,1,0.0348698013,2,0.017698925
  11  12  2 2 0,1,0.0774876028
  12

The weights in the generated FST correspond to the unweighted predictor scores in order of how they are defined in ``--predictors``.


Distributed decoding using the Grid Engine
-------------------------------------------

Large decoding jobs can be distributed over multiple nodes with the Grid Engine using the ``--range`` argument. First, we create a configuration file for SGNMT
which specifies the decoding parameters. Here is a example .ini file for distributing lattice rescoring on the WMT'15 English-German test set::

  $ cat scripts/grid/example.ini 
  src_test: data/test15.ids.en
  src_vocab_size: 50003
  trg_vocab_size: 50003
  predictors: nmt,fst
  fst_path: hiero/lats/%d.fst
  use_fst_weights: true
  predictor_weights: 2.7,24.4


Make sure that the .ini file does not contain ``output_path`` or ``range``. Next, open *scripts/grid/decode_on_grid_cpu_worker.sh* and, if
necessary, change the environment variables PATH, LD_LIBRARY_PATH, and PYTHONPATH as described on the :ref:`setup-label` page. Start the
distributed decoding with the following command::

  $ bash scripts/grid/decode_on_grid_cpu.sh 40 1:2169 scripts/grid/example.ini grid-output

This will submit an array of 40 jobs to the grid, and each worker calls decode.py with a different ``--range``. Worker jobs write their
output files to *grid-output/<worker-id>*, and their logs to *grid-output/logs*. When all workers are finished, the combination job
combines the output files and writes the requested output formats to *grid-output/out.%s*.
