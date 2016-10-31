.. SGNMT documentation master file, created by
   sphinx-quickstart on Tue May 17 17:32:32 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

SGNMT
========

SGNMT is an open-source framework for neural machine translation (NMT). The tool provides
a flexible platform which allows pairing NMT with various other models such as language models,
length models, or bag2seq models. It supports rescoring both n-best lists and lattice rescoring.
A wide variety of search strategies is available for complex decoding problems. 
SGNMT is compatible with Blocks/Theano and TensorFlow.

Contents
-------------
.. toctree::
   :maxdepth: 1

   setup
   tutorial
   command_line
   predictors
   decoders
   faq
   publications
   All modules <cam.sgnmt>

Quickstart
------------

For example, NMT decoding can be started with this command::

    $ python decode.py --predictors nmt --src_test sentences.txt

where sentences.txt is a plain (indexed) text file with sentences. Rescoring OpenFST
lattices with NMT is also straight-forward::

    $ python decode.py --predictors nmt,fst --fst_path lattices/%d.fst --src_test sentences.txt

See the :ref:`tutorial-label` for more examples.

Features
------------

- Syntactically guided neural machine translation (NMT lattice rescoring)
- NMT support for Blocks/Theano and TensorFlow
- n-best list rescoring with NMT
- Ensemble NMT decoding
- Forced NMT decoding
- Integrating language models (Kneser-Ney, NPLM, RNNLM)
- Different search algorithms (beam, A*, depth first search, greedy...)
- Target sentence length modelling
- NMT training with options for reshuffling and fixing word embeddings
- Bag2Sequence models and decoding algorithms
- Custom distributed word representations
- Joint decoding with word- and subword/character-level models
- Hypothesis recombination
- Heuristic search
- Neural word alignment
- ...

.. warning:: 

      SGNMT is designed for quick prototyping of new ideas. Therefore, it is not 
      optimised for productive purposes or decoding speed but aims to be as
      flexible as possible.

Project links
--------------

- Issue tracker: http://github.com/ucam-smt/sgnmt/issues
- Source code: http://github.com/ucam-smt/sgnmt

License
---------

The project is licensed under the Apache 2 license.

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`

