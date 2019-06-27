
.. _tutorial_pytorch-label:

Tutorial: fairseq (PyTorch)
===========================

This tutorial describes how to use models trained with Facebook's fairseq toolkit. Please make sure that you have installed PyTorch and 
fairseq as described on the :ref:`setup-label` page. Verify your setup with::

  $ python $SGNMT/decode.py --run_diagnostics
  Checking Python3.... OK
  Checking PyYAML.... OK
  (...)
  Checking PyTorch.... OK (1.1.0)
  Checking fairseq.... OK (0.7.1)

This tutorial reproduces the `English-French WMT'14 example <https://fairseq.readthedocs.io/en/latest/getting_started.html>`_ in the fairseq docs
inside SGNMT. Download the pre-trained model with::

  curl https://dl.fbaipublicfiles.com/fairseq/models/wmt14.v2.en-fr.fconv-py.tar.bz2 | tar xvjf -

A full list of pre-trained fairseq translation models is available `here <https://github.com/pytorch/fairseq/blob/master/examples/translation/README.md>`_.

The fairseq *dictionary* format is different from SGNMT/OpenFST wmaps. Use awk to convert the fairseq dictionaries to wmaps::

  cat wmt14.en-fr.fconv-py/dict.en.txt | awk 'BEGIN{print "<epsilon> 0\n<s> 1\n</s> 2\n<unk> 3"}{print $1" "(NR+3)}' > wmt14.en-fr.fconv-py/wmap.bpe.en
  cat wmt14.en-fr.fconv-py/dict.fr.txt | awk 'BEGIN{print "<epsilon> 0\n<s> 1\n</s> 2\n<unk> 3"}{print $1" "(NR+3)}' > wmt14.en-fr.fconv-py/wmap.bpe.fr

The ``fairseq`` predictor loads a fairseq model from ``fairseq_path``. Additionally, ``indexing_scheme`` needs to be set to ``fairseq`` as fairseq uses
different reserved IDs (e.g. the default end-of-sentence ID is 1 in SGNMT and T2T but 2 in fairseq). The full SGNMT config file for running the
model in an interactive shell like ``fairseq-interactive`` is::

  verbosity: debug
  input_method: shell

  predictors: fairseq
  indexing_scheme: fairseq
  fairseq_path: wmt14.en-fr.fconv-py/model.pt
  fairseq_lang_pair: en-fr

  bpe_codes: wmt14.en-fr.fconv-py/bpecodes
  src_wmap: wmt14.en-fr.fconv-py/wmap.bpe.en
  trg_wmap: wmt14.en-fr.fconv-py/wmap.bpe.fr
  preprocessing: bpe@@
  postprocessing: bpe@@

Note that fairseq uses length normalization by default, which can be activated in SGNMT by adding the following two lines to the config file::

  combination_scheme: length_norm
  early_stopping: false

This reproduces the decoding result and scores in the `fairseq docs <https://fairseq.readthedocs.io/en/latest/getting_started.html#evaluating-pre-trained-models>`_::

  $ python $SGNMT/decode.py --config_file fairseq.ini
  2019-06-26 15:10:40,787 INFO: Setting up fairseq library...
  | [en] dictionary: 43771 types
  | [fr] dictionary: 43807 types
  2019-06-26 15:10:40,864 INFO: Loading fairseq model(s) from wmt14.en-fr.fconv-py/model.pt
  2019-06-26 15:10:47,614 INFO: Initialized predictor fairseq (weight: 1.0)
  Starting interactive mode...
  PID: 11786
  Display help with 'help'
  Quit with ctrl-d or 'quit'
  sgnmt> Why is it rare to discover new marine mammal species ?
  2019-06-26 15:12:06,684 INFO: Start time: 1561558326.6844926
  2019-06-26 15:12:06,684 INFO: Next sentence (ID: 1): Why is it rare to discover new marine mammal species ?
  2019-06-26 15:12:06,685 DEBUG: BPE segmentation: 'Why is it rare to discover new marine mammal species ?' => 'Why is it rare to discover new marine mam@@ mal species ?' (5933 18 39 7019 9 7631 75 2269 21907 6082 988 185)
  2019-06-26 15:12:08,772 INFO: Decoded (ID: 1): Pourquoi est @-@ il rare de découvrir de nouvelles espèces de mammifères marins ?
  2019-06-26 15:12:08,772 INFO: Stats (ID: 1): score=-0.152505 num_expansions=58 time=2.09
  2019-06-26 15:12:08,772 INFO: Decoding finished. Time: 2.09

