
Command-line reference
=======================

SGNMT provides ``decode.py`` for decoding and ``train.py`` for NMT training. The
neural word alignment script ``align.py`` is only available for the Blocks 
implementation. The scripts can be configured via command line or configuration file. 
For a quick overview of available parameters use ``--help``::

    python decode.py --help
    python batch_decode.py --help
    python train.py --help
    python align.py --help

The complete and detailed list of parameters is provided below.

Decoding
---------

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_parser
   :prog: decode.py

Batch Decoding (Blocks only)
----------------------------

This is a fast decoder for pure NMT which does not process sentences
in a sequential order. It is optimized for GPU decoding. For maximum
decoding speed we recommend using the Theano flags ``lib.cnmem=1,allow_gc=False``
and the most recent versions of cuDNN and Theano. Not implemented for 
TensorFlow.

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_batch_decode_parser
   :prog: batch_decode.py

Training (Blocks only)
----------------------

The training script follows the NMT training example in blocks, but it adds an
option for enabling reshuffling the training data between epochs, and fixing
word embedding which might be used in later training stages.

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_train_parser
   :prog: train.py

Alignment (Blocks only)
-----------------------

Only available for the Blocks (Theano) NMT engine. Supports two different
neural word alignment models which both utilize the concept of attention in
NMT.

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_align_parser
   :prog: align.py

