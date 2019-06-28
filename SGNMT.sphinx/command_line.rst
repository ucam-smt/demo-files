
Command-line reference
=======================

The main runner script in SGNMT is ``decode.py``. The script can be configured 
via command line or configuration file. 
For a quick overview of available parameters use ``--help``::

    python decode.py --help

The complete and detailed list of parameters is provided below.

Besides ``decode.py`` following additional scripts are available:

  * ``extract_scores_along_reference.py``: Generates a JSON file which contains the complete posteriors of all
    predictors along a reference decoding path. Can be used for tuning predictor weights. Same arguments as ``decode.py``.
  * ``scripts/apply_wmap.py``: Applies word maps to strings.
  * ``scripts/extend_wmap.py``: Extends a word map with new words.
  * ``scripts/apply_bpe_with_eow.py``: Version of ``apply_bpe.py`` in `Rico Sennrich's subword-nmt repo <https://github.com/rsennrich/subword-nmt>`_ that is
    compatible with SGNMT's BPE style (no @@ separator, keep </w> tokens).
  * ``scripts/mert.py``: Basic MERT script for tuning SGNMT predictor weights on 1-best translations.
  * ``scripts/sge/``: Script for distributed SGNMT decoding on the Sun Grid Engine.

Decoding
---------

.. argparse::
   :module: cam.sgnmt.ui
   :func: get_parser
   :prog: decode.py

