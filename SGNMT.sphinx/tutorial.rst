
.. _tutorial-label:

Tutorial: Basics (T2T)
======================

This tutorial describes common use cases of SGNMT. We will use SGNMT with Tensor2Tensor backend in this
tutorial. Please make sure that you have installed (at least) OpenFST and Tensor2Tensor as described 
on the :ref:`setup-label` page. Verify your setup with::

  $ python $SGNMT/decode.py --run_diagnostics
  Checking Python3.... OK
  Checking PyYAML.... OK
  Checking TensorFlow.... OK (1.13.1)
  Checking Tensor2Tensor.... OK
  Checking OpenFST.... OK (openfst_python)
  (...)

If you are not willing to install these dependencies, you are still encouraged to read through this tutorial since it
illustrates a number of general concepts in SGNMT.

The tutorial data is available under the following DOI:

http://dx.doi.org/TODO (We are in the process of publishing the data under a DOI. In the meantime, please write fs439@cam.ac.uk to get access to this data)

Please download the archive and extract it::

  $ tar xzf tutorial-ende-wmt19.tar.gz
  $ cd tutorial-ende-wmt19

This tarball contains NMT model files and translation lattices for replicating some of our results in
our `WMT'19 English-German submission <https://arxiv.org/abs/1906.05447>`_. The directory structure is as follows:

* *./data/*: Preprocessed news-test2018 test set, word maps and BPE files.
* *./ini/*: Example SGNMT configuration files.
* *./models/ende/*: Tensor2Tensor English-German Transformer models.
* *./supplementary/*: SMT translation lattices and n-gram posteriors for MBR. The `ucam-smt tutorial <http://ucam-smt.github.io/tutorial/nmt.html>`_ explains how to generate translation lattices for SGNMT.
* *./scripts/*: contains helper scripts for preprocessing.


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

Preprocessing
----------------------------------------

The models in this tutorial are trained on preprocessed data (Moses tokenization + truecasing). Preprocessed files are provided in 
the tarball. Alternatively, the ``./scripts/preprocess_??.sh`` scripts can be used for preprocessing::

  echo 'A mental asylum, where today young people are said to meet.' | ./scripts/preprocess_en.sh
  a mental asylum , where today young people are said to meet . 

Note that in order to use the preprocessing scripts you need to change the paths to Moses in the scripts.

Pure NMT decoding (single)
----------------------------------------

All SGNMT options can be specified either as command line arguments or in configuration files. Options in configuration files are prioritized over command line arguments.
Simple NMT decoding needs a single ``t2t`` predictor::

  predictors: t2t

The ``t2t`` predictor itself requires additional options that set the vocabulary sizes, model location, and t2t problem and hparams set::

  pred_src_vocab_size: 35627
  pred_trg_vocab_size: 35627
  t2t_model: transformer
  t2t_checkpoint_dir: models/ende/base/
  t2t_problem: translate_ende_wmt32k
  t2t_hparams_set: transformer_base_v2

These options are summarized in ``ini/base.ini``. Use the ``src_test`` and ``range`` options to translate the first two sentences of the test set::

  $ python $SGNMT/decode.py --config_file ini/base.ini --src_test data/test18.ende.bpe.en --range 1:2
  (...)
  2019-06-24 11:32:47,344 INFO: Next sentence (ID: 1): 14828 5524 16148 3851 7721 22779 3739 3910 5314 4104 4905 3675 3646 5390
  2019-06-24 11:32:51,181 INFO: Decoded (ID: 1): 15351 5524 16148 3851 7909 15056 3637 3674 6738 8516 3789 3674 6043 16507 3880
  2019-06-24 11:32:51,181 INFO: Stats (ID: 1): score=-5.486438 num_expansions=51 time=3.84
  2019-06-24 11:32:51,181 INFO: Next sentence (ID: 2): 3667 6203 13502 3637 4678 5149 7703 4499 3771 5598 3678 8087 3642
  2019-06-24 11:32:54,017 INFO: Decoded (ID: 2): 3787 15786 4602 30449 3637 5478 4909 13833 5058 7373 3896 8681 3642
  2019-06-24 11:32:54,018 INFO: Stats (ID: 2): score=-8.179755 num_expansions=50 time=2.84
  2019-06-24 11:32:54,018 INFO: Decoding finished. Time: 6.67

Here, sentences are in *indexed* representation as sequence of numerical token IDs on the subword level. The ``apply_wmap.py`` script can be used to
convert between indexed and plain text representations::

  # Preserve subword segmentation
  $ echo '15351 5524 16148 3851 7909 15056 3637 3674 6738 8516 3789 3674 6043 16507 3880' | python $SGNMT/scripts/apply_wmap.py -m data/wmap.bpe.ende -d i2s
  München</w> 18 56</w> :</w> vier</w> Karten</w> ,</w> die</w> Ihren</w> Blick</w> auf</w> die</w> Stadt</w> verändern</w> werden</w>

  # Generate original (word-level) segmentation
  echo '15351 5524 16148 3851 7909 15056 3637 3674 6738 8516 3789 3674 6043 16507 3880' | python $SGNMT/scripts/apply_wmap.py -m data/wmap.bpe.ende -d i2s -t eow
  München 1856 : vier Karten , die Ihren Blick auf die Stadt verändern werden

Processing indexed files often leads to a clearer setup, especially when many external supplementary files are involved to help decoding as in lattice or n-best 
rescoring or MBR-based NMT. However, for convenience, SGNMT can also operate on string representations by using ``ini/bpe.ini``::

  wmap: data/wmap.bpe.ende
  bpe_codes: data/bpe.train.ende
  preprocessing: bpe
  postprocessing: bpe

Decode with both ini files::

  $ python $SGNMT/decode.py --config_file ini/base.ini,ini/bpe.ini --src_test data/test18.ende.preprocess.en --range 1:2
  (...)
  2019-06-24 11:58:16,067 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 11:58:19,923 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihren Blick auf die Stadt verändern werden
  2019-06-24 11:58:19,923 INFO: Stats (ID: 1): score=-5.486438 num_expansions=51 time=3.86
  2019-06-24 11:58:19,923 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 11:58:22,734 INFO: Decoded (ID: 2): ein geistiges Asyl , wo heute junge Menschen sollen sich treffen .
  2019-06-24 11:58:22,734 INFO: Stats (ID: 2): score=-8.179755 num_expansions=50 time=2.81
  2019-06-24 11:58:22,734 INFO: Decoding finished. Time: 6.67

SGNMT also supports a shell mode for interactive use::

  $ python $SGNMT/decode.py --config_file ini/base.ini,ini/bpe.ini --input_method shell
  (...)
  Starting interactive mode...
  PID: 9395
  Display help with 'help'
  Quit with ctrl-d or 'quit'
  sgnmt> a mental asylum , where today young people are said to meet .
  2019-06-24 12:02:01,986 INFO: Start time: 1561374121.986785
  2019-06-24 12:02:01,987 INFO: Next sentence (ID: 1): a mental asylum , where today young people are said to meet .
  2019-06-24 12:02:05,769 INFO: Decoded (ID: 1): ein geistiges Asyl , wo heute junge Menschen sollen sich treffen .
  2019-06-24 12:02:05,769 INFO: Stats (ID: 1): score=-8.179755 num_expansions=50 time=3.78
  2019-06-24 12:02:05,769 INFO: Decoding finished. Time: 3.78
  sgnmt> config beam 10
  Setting beam=10...
  (...)
  sgnmt> a mental asylum , where today young people are said to meet .
  2019-06-24 12:03:01,519 INFO: Start time: 1561374181.5197287
  2019-06-24 12:03:01,520 INFO: Next sentence (ID: 1): a mental asylum , where today young people are said to meet .
  2019-06-24 12:03:09,498 INFO: Decoded (ID: 1): ein geistiges Asyl , wo sich heute junge Menschen treffen sollen .
  2019-06-24 12:03:09,498 INFO: Stats (ID: 1): score=-7.389152 num_expansions=123 time=7.98
  2019-06-24 12:03:09,498 INFO: Decoding finished. Time: 7.98
  

Pure NMT decoding (ensemble)
----------------------------------------

Ensemble decoding can be realized by using multiple ``t2t`` predictors and overriding some of the predictor-specific options::

  predictors: t2t, t2t

  t2t_checkpoint_dir: models/ende/base/
  t2t_hparams_set: transformer_base_v2

  t2t_checkpoint_dir2: models/ende/big/
  t2t_hparams_set2: transformer_big

This config file ensembles a base and a big Transformer model::

  $ python $SGNMT/decode.py --config_file ini/ensemble.ini,ini/bpe.ini --src_test data/test18.ende.preprocess.en --range 1:2
  (...)
  2019-06-24 12:27:56,752 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 12:28:10,596 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihren Blick auf die Stadt verändern werden 
  2019-06-24 12:28:10,596 INFO: Stats (ID: 1): score=-10.303408 num_expansions=52 time=13.84
  2019-06-24 12:28:10,596 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 12:28:21,765 INFO: Decoded (ID: 2): ein geistiges Asyl , wo sich heute junge Menschen treffen sollen . 
  2019-06-24 12:28:21,766 INFO: Stats (ID: 2): score=-14.571033 num_expansions=50 time=11.17
  2019-06-24 12:28:21,766 INFO: Decoding finished. Time: 25.01


Generating output files
----------------------------------------

SGNMT supports a number of output formats to dump the explored search space to the file system:

* *text*: First best translations in plain text
* *nbest*: n-best list in Moses format
* *sfst*: OpenFST translation lattices with standard arcs
* *fst*: OpenFST translation lattices with sparse tuple arcs
* *ngram*: MBR-style n-gram posteriors
* *timecsv*: CSV with predictor scores over time

The ``outputs`` option activates the different output formats, and ``output_path`` sets the path to the output files::

  $ python $SGNMT/decode.py --config_file ini/ensemble.ini,ini/bpe.ini \
       --outputs text,nbest,sfst,timecsv \
       --output_path ensemble-output.%s \
       --src_test data/test18.ende.preprocess.en --range 1:2

The above command generates the files ``ensemble-output.text`` that contains the translations in plain text, and ``ensemble-output.nbest``
that is an n-best list in Moses format that keeps the scores of both predictors (i.e. ensembled models) separate::

  $ cat ensemble-output.nbest
  0 ||| München 1856 : vier Karten , die Ihren Blick auf die Stadt verändern werden  ||| t2t= -5.486438 t2t2= -4.816970 ||| -10.303408
  0 ||| München 1856 : vier Karten , die Ihre Sicht auf die Stadt verändern werden  ||| t2t= -6.245763 t2t2= -4.711694 ||| -10.957457
  0 ||| München 1856 : vier Karten , die Ihren Blick auf die Stadt verändern .  ||| t2t= -6.356879 t2t2= -6.373269 ||| -12.730148
  1 ||| ein geistiges Asyl , wo sich heute junge Menschen treffen sollen .  ||| t2t= -7.389152 t2t2= -7.181882 ||| -14.571033
  1 ||| ein geistiges Asyl , wo sich heute junge Leute treffen sollen .  ||| t2t= -8.740399 t2t2= -7.823516 ||| -16.563915
  1 ||| ein geistiges Asyl , wo heute junge Menschen sich treffen sollen .  ||| t2t= -8.870988 t2t2= -8.109677 ||| -16.980665

Additionally, two directories are created. ``ensemble-output.timecsv`` contains CSV files with predictor scores in each time step for each hypothesis. ``ensemble-output.sfst``
consists of output translation lattices in OpenFST format::

  $ fstprint --isymbols=data/wmap.bpe.ende --acceptor ensemble-output.sfst/1.fst
  0	1	<s>	10.3034077
  1	2	München</w>
  2	3	18
  3	4	56</w>
  4	5	:</w>
  5	6	vier</w>
  6	7	Karten</w>
  7	8	,</w>
  8	9	die</w>
  9	10	Ihre</w>	0.654048979
  9	11	Ihren</w>
  10	12	Sicht</w>
  11	13	Blick</w>
  12	14	auf</w>
  13	15	auf</w>
  14	16	die</w>
  15	17	die</w>
  16	18	Stadt</w>
  17	19	Stadt</w>
  18	20	verändern</w>
  19	21	verändern</w>
  20	22	werden</w>
  21	22	werden</w>
  21	22	.</w>	2.42674088
  22	23	</s>
  23


Lattice rescoring
----------------------------------------

For restricting NMT to an (SMT) translation lattice as proposed in our `ACL'16 paper <https://arxiv.org/abs/1605.04569>`_, use the *fst* predictor::

  predictors: t2t, fst
  fst_path: supplementary/smt.lats_test18/%d.fst
  (...)

Decode with::

  $ python $SGNMT/decode.py --config_file ini/rescoring.ini --range 1:2
  (...)
  2019-06-24 13:48:18,317 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 13:48:22,418 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihre Sicht auf die Stadt verändern werden .
  2019-06-24 13:48:22,418 INFO: Stats (ID: 1): score=-7.547943 num_expansions=53 time=4.10
  2019-06-24 13:48:22,418 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 13:48:25,212 INFO: Decoded (ID: 2): ein geistiges Asyl , wo heute junge Menschen sollen sich treffen .
  2019-06-24 13:48:25,213 INFO: Stats (ID: 2): score=-8.179755 num_expansions=48 time=2.79

This command loads the determinised lattice ``./supplementary/smt.lats_test18/?.fst`` from the file system and runs the NMT beam search decoder on it. For non-deterministic lattices 
use the ``nfst`` predictor instead. By default, SGNMT ignores the scores in the translation lattices and uses the FST as unweighted constrained. To also take the FST weights
into account, set ``use_fst_weights`` to true and balance NMT vs. SMT score with ``predictor_weights``::

  python $SGNMT/decode.py --config_file ini/rescoring.ini --predictor_weights 2.0,1.0 --use_fst_weights true --range 1:2
  (...)
  2019-06-24 13:50:01,530 INFO: Initialized predictor t2t (weight: 2.0)
  2019-06-24 13:50:01,530 INFO: Initialized predictor fst (weight: 1.0)
  2019-06-24 13:50:01,531 INFO: Start time: 1561380601.5318987
  2019-06-24 13:50:01,531 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 13:50:05,488 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihre Sicht auf die Stadt verändern werden .
  2019-06-24 13:50:05,488 INFO: Stats (ID: 1): score=-30.180038 num_expansions=51 time=3.96
  2019-06-24 13:50:05,488 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 13:50:08,385 INFO: Decoded (ID: 2): ein geistiges Asyl , wo heute junge Menschen sollen zusammenkommen .
  2019-06-24 13:50:08,385 INFO: Stats (ID: 2): score=-23.774222 num_expansions=50 time=2.90
  2019-06-24 13:50:08,385 INFO: Decoding finished. Time: 6.85


Decoders
----------------------------------------

Different search strategies (*decoders*) can be used to explore the space spanned by the predictors. The default is beam decoding
with beam size of 4 (change beam size with ``beam`` option). Alternative decoders can be selected with the ``decoder`` option::

  $ python $SGNMT/decode.py --config_file ini/rescoring.ini --decoder greedy --range 1:2
  (...)
  2019-06-24 14:24:15,744 INFO: Start time: 1561382655.7441242
  2019-06-24 14:24:15,744 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 14:24:17,693 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihre Sicht auf die Stadt verändern werden .
  2019-06-24 14:24:17,693 INFO: Stats (ID: 1): score=-7.547943 num_expansions=17 time=1.95
  2019-06-24 14:24:17,693 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 14:24:18,511 INFO: Decoded (ID: 2): ein geistiges Asyl , wo heute junge Menschen sollen sich treffen .
  2019-06-24 14:24:18,511 INFO: Stats (ID: 2): score=-8.179755 num_expansions=14 time=0.82
  2019-06-24 14:24:18,511 INFO: Decoding finished. Time: 2.77

Greedy decoding requires fewer node expansions (compare ``num_expansions`` with the previous section), but is more prone to search errors. Depth-first search
is an exact inference scheme that is guaranteed to find the global best score::

  $ python $SGNMT/decode.py --config_file ini/rescoring.ini --decoder dfs --range 1:2
  (...)
  2019-06-24 14:28:10,696 INFO: Start time: 1561382890.6964235
  2019-06-24 14:28:10,696 INFO: Next sentence (ID: 1): Munich 1856 : four maps that will change your view of the city
  2019-06-24 14:28:15,261 INFO: Decoded (ID: 1): München 1856 : vier Karten , die Ihre Sicht auf die Stadt verändern werden .
  2019-06-24 14:28:15,261 INFO: Stats (ID: 1): score=-7.547943 num_expansions=61 time=4.56
  2019-06-24 14:28:15,261 INFO: Next sentence (ID: 2): a mental asylum , where today young people are said to meet .
  2019-06-24 14:28:21,248 INFO: Decoded (ID: 2): ein geistiges Asyl , wo heute junge Menschen sollen sich treffen .
  2019-06-24 14:28:21,248 INFO: Stats (ID: 2): score=-8.179755 num_expansions=104 time=5.99
  2019-06-24 14:28:21,248 INFO: Decoding finished. Time: 10.55

In this case, even greedy decoding finds the global best hypotheses.


MBR-based NMT (UCAM at WMT19)
----------------------------------------

In our `EACL 2017 paper <http://arxiv.org/abs/1612.03791>`_ we described how to use n-gram posteriors extracted from a Hiero lattice to improve NMT. 
External n-gram probabilities can be introduced to SGNMT via the ``ngramc`` predictor. Since ``ngramc`` can yield positive scores, ``early_stopping``
needs to be set to ``false`` for MBR-based decoding. The ``ini/ucam-wmt19-base.ini`` config file additionally ensembles with a Transformer
language model to reproduce our base single system in our WMT19 submission::

  $ python $SGNMT/decode.py --config_file ini/ucam-wmt19-base.ini --range 1:2
  (...)
  2019-06-25 11:03:42,207 INFO: Next sentence (ID: 1): 14828 5524 16148 3851 7721 22779 3739 3910 5314 4104 4905 3675 3646 5390
  2019-06-25 11:03:42,207 DEBUG: Loading n-gram scores from supplementary/smt.ngramc_test18/1.txt...
  2019-06-25 11:03:59,037 INFO: Decoded (ID: 1): 15351 5524 16148
  2019-06-25 11:03:59,037 INFO: Stats (ID: 1): score=-11.173564 num_expansions=108 time=16.83
  2019-06-25 11:03:59,037 INFO: Next sentence (ID: 2): 3667 6203 13502 3637 4678 5149 7703 4499 3771 5598 3678 8087 3642
  2019-06-25 11:03:59,038 DEBUG: Loading n-gram scores from supplementary/smt.ngramc_test18/2.txt...
  2019-06-25 11:04:13,880 INFO: Decoded (ID: 2): 3787 15786 4602 30449 3637 5478 3896 4909 22992 8681 7373 3642
  2019-06-25 11:04:13,881 INFO: Stats (ID: 2): score=-25.113689 num_expansions=104 time=14.84



Distributed decoding using the Grid Engine
-------------------------------------------

Large decoding jobs can be distributed over multiple nodes with queueing systems like the Sun Grid Engine. SGNMT comes with an example script
for distributed decoding::

  $ bash $SGNMT/scripts/sge/decode_cpu.sh 100 ini/rescoring.ini output-sge

This will submit an array of 100 jobs to the grid, and each worker calls ``$SGNMT/decode.py`` with the ``range`` option pointing to a file that assigns
sentence IDs to workers. Worker jobs write their output files to ``output-sge/<worker-id>``, and their logs to ``output-sge/logs``. When all workers are finished, the combination job
combines the output files, writes the requested output formats to ``output-sge/out.%s``, and touches ``output-sge/DONE``.

This script works on the air-stack of the Cambridge Engineering Department speech group, and can serve as template for setting up distributed
decoding elsewhere. Consider changing the ``-l`` options of the ``qsub`` commands in ``decode_cpu.sh`` and pointing the ``source`` command in
``decode_cpu_worker.sh`` to your ``<ACTIVATE.SH>`` script.


BLEU scores
-------------------------------------------

The tutorial tarball contains the ``./scripts/eval_test18_ende.sh`` script that can be used to compute BLEU scores from indexed subword-level translations that
are comparable to `official WMT results <http://matrix.statmt.org/>`_ (adjust path to Moses before use)::

  # e.g. out.text from ini/ucam-wmt19-big.ini 
  $ cat output-sge/out.text | ./scripts/eval_test18_ende.sh 
  (...)
  BLEU = 47.95, 74.42/53.76/41.42/32.67 (BP=0.994164, ratio=0.994181342958491, hyp_len=63902, ref_len=64276)

The script generates a number of ``tmp.*`` files for closer inspection. Here are the expected BLEU scores for the ini files in this tutorial:

====================   ============
Config File            BLEU
====================   ============
base.ini               43.8
ucam-wmt19-base.ini    45.1
big.ini                47.8
ucam-wmt19-big.ini     48.0
====================   ============

These results correspond to the single system results in rows 2 and 4 of Table 6 in our `WMT19 system description paper <https://arxiv.org/abs/1906.05447>`_.
Note that our single NMT result (48.0 BLEU) is very close to the winning WMT18 system (Microsoft-Marian: 48.3 BLEU) that was an ensemble of four NMT systems.
