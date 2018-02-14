
Command-line reference
=======================

The main runner script in SGNMT is ``decode.py``. The script can be configured 
via command line or configuration file. 
For a quick overview of available parameters use ``--help``::

    python decode.py --help

The complete and detailed list of parameters is provided below.

SGNMT supports NMT training with Blocks/Theano. However, this will be removed in
future releases since Theano has been discontinued. We refer to other packages
such as Tensor2Tensor or the seq2seq TF tutorial for training, which are
supported by the SGNMT decoder.

Besides ``decode.py`` following additional scripts are available:

  * ``extract_scores_along_reference.py``: Generates a JSON file which contains the complete posteriors of all
    predictors along a reference decoding path. Can be used for tuning predictor weights. Same arguments as ``decode.py``.
  * ``train.py``: NMT training and shrinking script for attentional RNN models (Blocks/Theano only).
  * ``batch_decode.py``: Very fast beam decoder (over 800 words per second on a Titan X GPU) for pure NMT decoding (Blocks/Theano only).
  * ``align.py``: Neural word alignment using attentional RNN seq2seq models (Blocks/Theano only).

Decoding
---------

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_parser
   :prog: decode.py

