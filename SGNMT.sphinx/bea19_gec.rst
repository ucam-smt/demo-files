
.. _bea19_gec-label:

Tutorial:  Grammatical error correction
==============================================================================

This tutorial reproduces the single system results of the Cambridge University Engineering Department's submissions to the
`BEA-2019 shared task on grammatical error correction <https://www.cl.cam.ac.uk/research/nl/bea2019st/>`_. Details about the
submissions can be found in the system description paper:

  https://arxiv.org/TODO

The tutorial data is available under the following DOI:

http://dx.doi.org/TODO (We are in the process of publishing the data under a DOI. In the meantime, please write fs439@cam.ac.uk to get access to this data)

Please download the archive and extract it::

  $ tar xzf tutorial-bea2019-gec.tar.gz
  $ cd tutorial-bea2019-gec


Restricted track submission
----------------------------------------

Our restricted track systems are purely neural. The base system (last row in Tab. 9 in the paper) can be run using the ``ini/restricted-base_dev.ini`` config file::

  predictors: t2t

  src_test: data/dev.ne
  config_file: ini/bpe.ini

  pred_src_vocab_size: 34937
  pred_trg_vocab_size: 34937
  t2t_problem: translate_ende_wmt32k
  t2t_model: transformer
  t2t_hparams_set: transformer_base_v2
  t2t_checkpoint_dir: models/nmt/base/

  outputs: nbest,text

Decode as usual:: 

  python $SGNMT/decode.py --config_file ini/restricted-base_dev.ini  --range 68
  (...)
  2019-06-28 17:43:46,168 INFO: Next sentence (ID: 68): After many years he still dream to become a super hero .
  2019-06-28 17:43:49,687 INFO: Decoded (ID: 68): After many years he still dreams of becoming a super hero .
  2019-06-28 17:43:49,687 INFO: Stats (ID: 68): score=-2.711742 num_expansions=45 time=3.52
  2019-06-28 17:43:49,687 INFO: Decoding finished. Time: 3.52

`ERRANT <https://github.com/chrisjbryant/errant>`_ scores can be computed as described by the `shared task organizers <https://www.cl.cam.ac.uk/research/nl/bea2019st/>`_::

  python3 $ERRANT_HOME/parallel_to_m2.py -orig data/dev.ne -cor <path-to-sgnmt-output-file> -out tmp.m2
  python3 $ERRANT_HOME/compare_m2.py -hyp tmp.m2 -ref <dev-set-reference-m2>

Scores might differ slightly from the ones in the paper due to different Python, SGNMT, TensorFlow, and Tensor2Tensor versions. Configuration files for the big single
NMT systems (rows 3 and 4 in Tab. 10) are provided as ``ini/restricted-big_dev.ini`` and ``ini/restricted-big+lm_dev.ini``.


Low-resource track submission
----------------------------------------

The low-resource track does not permit the use of parallel training data except the BEA-2019 development set with around 4K sentence pairs. As
explained in the paper, our submission to this track works by constructing the search space with a cascade of FST compositions, and then
rescoring that search space with neural language models. The final FSTs that can be used for rescoring are in ``./supplementary/composed_fsts/d_s_i``
(*d_s_i* stands for the composition cascade *deletion-substitution-insertion*). The paper describes the search space as a single FST. In this
tutorial, we use three FSTs instead, all with the same topology but with different scores: FSTs in '100' contain only deletion scores, in '010'
only substitution scores, and in '001' only insertion scores. While composing these three FSTs to a single FST would be more efficient, keeping
them separate is more flexible as it allows us to scale the different penalties directly inside SGNMT by simply using three different ``fst`` predictors 
with different predictor weights::

  predictors: t2t,fst,fst,fst
  predictor_weights: 0.25,0.75,0.75,0.9375
  beam: 8

  src_test: data/dev.ne
  config_file: ini/bpe.ini

  fst_path: supplementary/composed_fsts/d_s_i/100/dev/%d.fst
  fst_path2: supplementary/composed_fsts/d_s_i/010/dev/%d.fst
  fst_path3: supplementary/composed_fsts/d_s_i/001/dev/%d.fst
  use_fst_weights: true

  pred_src_vocab_size: 34937
  pred_trg_vocab_size: 34937
  t2t_problem: languagemodel_lm1b32k
  t2t_model: transformer
  t2t_hparams_set: transformer_big
  t2t_checkpoint_dir: models/lm/big/

  outputs: nbest,text


This SGNMT config file for the BEA-2019 dev set is stored as ``ini/lowresource-1lm_dev.ini`` which corresponds to row 4 in Tab. 2 in the paper. Our best
system on the low-resource track (last row in Tab. 2) bumps up the beam size to 32 and adds another LM (``ini/lowresource-2lm_dev.ini``). Note that
these are evaluation systems for which decoding time is secondary. We recommend using distributed decoding and/or GPUs.

Again, ERRANT scores might differ slightly from the figures reported in the paper due to different versions of Python, TensorFlow, and Tensor2Tensor.

For your reference, we also provide resources and scripts to build the composition cascade from scratch. Your starting point to learn more about
how to build these FSTs would be ``./supplementary/README``. Note that some of the scripts require external dependencies such as spaCy, hunspell,
and `lmgec-lite <https://github.com/chrisjbryant/lmgec-lite>`_.


