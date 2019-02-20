
.. _examples-label:

Examples
===============================

SGNMT supports many different options, and small changes in the decoder configuration sometimes lead
to very different results. This page contains a list of SGNMT configuration files which have been used
in our group. Details such as paths and vocabulary sizes are exemplary as we do not provide model files,
but we hope that this list is still useful as blueprint for your own experiments.

University of Cambridge submission to WMT18 (Tensor2Tensor)
***********************************************************

These are the ini-files for the final decoding passes. Please write to fs439@cam.ac.uk for
access to the trained models.

English-German::

    predictors: t2t,t2t,ngramc,ngramc,ngramc,ngramc,wc
    predictor_weights: 5.7,4.3,0.1,0.1,1.0,0.75,1.5
    src_test: /data/mifs_scratch/fs439/data/wmt18/test/indexed_bpe/test18ts.ende.bpe.en
    beam: 8
    early_stopping: false

    pred_src_vocab_size: 35627
    pred_trg_vocab_size: 35627
    indexing_scheme: t2t
    t2t_problem: translate_ende_wmt18

    # Relative transformer model
    t2t_checkpoint_dir: t2t_train/translate_ende_wmt18/transformer-transformer_relative_big_large_batch4/average.1000k/
    t2t_model: transformer
    t2t_hparams_set: transformer_relative_big

    # Transformer model
    t2t_checkpoint_dir2: t2t_train/translate_ende_wmt18/transformer-transformer_big_large_batch4/average.1000k
    t2t_model2: transformer
    t2t_hparams_set2: transformer_big

    # slicenet ngram posteriors
    ngramc_path: supplementary/ende2/ss.ngramc_test18ts/%d.txt

    # rnn ngram posteriors
    ngramc_path2: supplementary/ende2/rr.ngramc_test18ts/%d.txt

    # r2l ngram posteriors
    ngramc_path3: supplementary/ende2/ender.ngramc_test18ts/%d.txt

    # SDL posteriors
    ngramc_path4: supplementary/ende/sdl.ngramc_test18ts/%d.txt

    outputs: nbest,text,ngram

German-English::

    (like English-German with the following predictor weights)
    predictor_weights: 4.2,3.8,0.1,0.125,0.75,1.5,-1.2

Chinese-English::

    verbosity: debug
    predictors: t2t,t2t,ngramc,ngramc,ngramc,ngramc,wc
    predictor_weights: 6.5,5.5,0.375,0.375,0.375,0.5,-0.5
    src_test: /data/mifs_scratch/fs439/data/wmt18/test/indexed_bpe/test18.enzh.bpe.zh
    beam: 8
    early_stopping: false

    pred_src_vocab_size: 43738
    pred_trg_vocab_size: 34306
    indexing_scheme: t2t
    t2t_problem: translate_zhen_wmt18

    # Relative transformer model
    t2t_checkpoint_dir: t2t_train/translate_zhen_wmt18/transformer-transformer_relative_big_large_batch4/average.1000k/
    t2t_model: transformer
    t2t_hparams_set: transformer_relative_big

    # Transformer model
    t2t_checkpoint_dir2: t2t_train/translate_zhen_wmt18/transformer-transformer_big_large_batch4/average.1000k
    t2t_model2: transformer
    t2t_hparams_set2: transformer_big

    # slicenet ngram posteriors
    ngramc_path: supplementary/zhen2/ss.ngramc_test18/%d.txt

    # rnn ngram posteriors
    ngramc_path2: supplementary/zhen2/rr.ngramc_test18/%d.txt

    # r2l ngram posteriors
    ngramc_path3: supplementary/zhen2/zhenr.ngramc_test18/%d.txt

    # SDL posteriors
    ngramc_path4: supplementary/zhen/sdl.ngramc_test18/%d.txt

    outputs: nbest,text,ngram


Joint Word/BPE decoding with multisegbeam (Blocks/Theano)
***********************************************************

Ensemble of a word-to-word system (vocabulary size: 30003) and a bpe-to-bpe system using the ``multisegbeam`` 
decoding strategy, tested on WAT (ja-en)::

    predictors: nmt,altsrc_nmt
    src_test: data/dev.ids.ja
    altsrc_test: data/dev.bpe.ja
    decoder: multisegbeam
    multiseg_tokenizations: '30003:data/wmap.en,eow:data/wmap.bpe.en'

Ensemble of three BPE-based models (Blocks/Theano)
**************************************************

Fast decoding of three BPE-based NMT systems on ja-en WAT with GNMT coverage penalty::

    predictors: nmt,nmt,nmt
    src_test: data/dev.bpe.ja
    decoder: vanilla

    gnmt_beta: 0.01
    nmt_config: src_vocab_size=32081,trg_vocab_size=30123
    nmt_path2: ../jaen-wat-bpe2/train
    nmt_path3: ../jaen-wat-bpe3/train

Lattice rescoring with three NMT systems (Blocks/Theano)
********************************************************

Rescoring an SMT lattice on ja-en WAT with an ensemble of three NMT systems (ja-en WAT)::

    predictors: fst,nmt,nmt,nmt
    predictor_weights: 0.5,0.5,0.5,0.5
    src_test: data/test.bpe.ja
    early_stopping: false
    hypo_recombination: true

    fst_path: lats.bpe_test/%d.fst
    use_fst_weights: true

    gnmt_beta: 0.01
    nmt_config: src_vocab_size=32081,trg_vocab_size=30123
    nmt_path2: ../jaen-wat-bpe2/train
    nmt_path3: ../jaen-wat-bpe3/train

Iterative NMT beam search (Blocks/Theano)
**************************************************

Using the ``bucket`` decoding strategy for pure NMT decoding with 
multiple beam search passes::

    src_test: data/test15.ids.en
    decoder: bucket
    bucket_selector: iter
    max_node_expansions: 2000
    predictors: nmt
    length_normalization: true
    nmt_config: src_vocab_size=50003,trg_vocab_size=50003



MBR-based NMT with a 3-ensemble (Blocks/Theano)
**************************************************

Using MBR-style n-gram posteriors together with a ensemble of three NMT systems
on ja-en WAT::

    predictors: nmt,ngramc,wc,nmt,nmt
    predictor_weights: 0.53125,0.46875,0.46875,0.53125,0.53125
    src_test: data/test.bpe.ja
    allow_unk_in_output: false
    early_stopping: false
    hypo_recombination: true

    ngramc_path: lats.ngramc.smooth.bpe_test/%d.txt

    gnmt_beta: 0.01
    nmt_config: src_vocab_size=32081,trg_vocab_size=30123
    nmt_path2: ../jaen-wat-bpe2/train
    nmt_path3: ../jaen-wat-bpe3/train


MBR-based NMT with separately tuned Thetas (Blocks/Theano)
**********************************************************

Tuning the n-gram posterior weights for each n-gram order separately on
WMT15 en-de::

    predictors: ngramc,ngramc,ngramc,ngramc,wc,nmt
    predictor_weights: 1.0,0.603674,0.0950858,0.514882,0.713726,0.510412
    src_test: data/test15.ids.en
    beam: 2
    hypo_recombination: true
    allow_unk_in_output: false

    ngramc_path: lats.mapped.ngramc.smooth_test15/%d.txt
    ngramc_order: 1
    ngramc_order2: 2
    ngramc_order3: 3
    ngramc_order4: 4

    gnmt_beta: 0.2
    nmt_config: src_vocab_size=50003,trg_vocab_size=50003


Exhaustive n-best list rescoring with NMT (Blocks/Theano)
*********************************************************

Rescoring a complete n-best list on WMT15 en-de. The n-best list and the NMT system use different
word IDs::

    src_test: data/test15.ids.en
    decoder: dfs
    early_stopping: false
    predictors: idxmap_forcedlst,nmt
    src_idxmap: data/idxmap.org.test15.en
    trg_idxmap: data/idxmap.org.test15.de
    use_nbest_weights: false
    trg_test: ../ende-wmt15/results/hifst_test15.1000best
    nmt_config: src_vocab_size=50003,trg_vocab_size=50003


NMT with length model and neural language model (Blocks/Theano)
***************************************************************

Pairing NMT with a length model and a neural language model, and rescoring HiFST
translation lattices with the mix. The lattice and the LM use alternative word maps::

    src_test: data/test15.ids.en
    predictors: idxmap_fst,length,idxmap_nplm,nmt
    predictor_weights: 8.144021,0.579325,1.192874,4.347711
    src_idxmap: data/idxmap.org.test15.en
    trg_idxmap: data/idxmap.org.test15.de
    fst_path: lats_test15/%d.fst
    nmt_config: src_vocab_size=50003,trg_vocab_size=50003
    use_fst_weights: true
    length_model_weights: 0.252503399924538,1.26556504208994,0.0476145832475248,0.507108282728234,0.0706249583462012,0.00156446527534046,-0.0114873442886072,0.00724551243039656,-0.108343582699869,-0.225865854796484,0.183585648431748,-0.367378141618226
    src_test_raw: data/test15.en
    nplm_path: nplm/news12-14.de.nnlm.news12-14.5gram-model.large_8.50000.0.10.24.3186.10

10-Ensemble of diverse NMT systems (Blocks/Theano)
***************************************************************

Combining 10 NMT system under the Bayesian combination scheme, each with different
vocabulary sizes and word maps::

    src_test: data/test15.ids.en
    early_stopping: false
    predictors: nmt,nmt,nmt,nmt,nmt,nmt,nmt,nmt,idxmap_nmt,idxmap_nmt
    predictor_weights: 0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1
    combination_scheme: bayesian
    decoder: combibeam
    nmt_config2: saveto=./train.reshuffle
    nmt_config3: saveto=./train.adria,src_vocab_size=30003,trg_vocab_size=30003
    nmt_config4: saveto=./train.fixembedding,src_vocab_size=50003,trg_vocab_size=50003
    nmt_config5: saveto=./train.mteval2
    nmt_config6: saveto=./train.mteval3
    nmt_config7: saveto=./train.large,src_vocab_size=60003,trg_vocab_size=60003
    nmt_config8: saveto=./train.mteval4,src_vocab_size=50003,trg_vocab_size=50003
    nmt_config9: saveto=./train.ext100k1
    nmt_config10: saveto=./train.ext100k2
    src_idxmap: ../ende-wmt15-ext100k1/data/idxmap.ext100k1.test15.en
    trg_idxmap: ../ende-wmt15-ext100k1/data/idxmap.ext100k1.test15.de
    src_idxmap2: ../ende-wmt15-ext100k2/data/idxmap.ext100k2.test15.en
    trg_idxmap2: ../ende-wmt15-ext100k2/data/idxmap.ext100k2.test15.de

