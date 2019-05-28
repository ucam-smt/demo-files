.. SGNMT documentation master file, created by
   sphinx-quickstart on Tue May 17 17:32:32 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

SGNMT
========

SGNMT is an open-source framework for neural machine translation (NMT) and other sequence prediction
tasks. The tool provides a flexible platform which allows pairing NMT with various other models such 
as language models, length models, or bag2seq models. It supports rescoring both n-best lists and lattices.
A wide variety of search strategies is available for complex decoding problems. 

SGNMT is compatible with multiple NMT implementations based on `Theano <http://deeplearning.net/software/theano/>`_
(`Blocks <http://blocks.readthedocs.io/en/latest/>`_) and `TensorFlow <https://www.tensorflow.org/>`_ (the
`extended seq2seq tutorial <https://github.com/ehasler/tensorflow>`_ and `tensor2tensor <https://github.com/tensorflow/tensor2tensor>`_).

Contents
-------------
.. toctree::
   :maxdepth: 1

   setup
   tutorial
   adding_components
   kyoto_nmt
   bea19_gec
   command_line
   predictors
   decoders
   examples
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
- NMT support in Theano (Blocks) and TensorFlow (Tensor2Tensor)
- Target-side syntax for NMT
- n-best list rescoring with NMT
- Integrating external n-gram posterior probabilities used in MBR
- Ensemble NMT decoding
- Forced NMT decoding
- Integrating language models (Kneser-Ney, NPLM, RNNLM)
- Different search algorithms (beam, A*, depth first search, greedy...)
- Target sentence length modelling
- Bag2Sequence models and decoding algorithms
- Joint decoding with word- and subword/character-level models
- Hypothesis recombination
- Heuristic search
- Extensions to NMT training in Blocks (reshuffling, fixing and customizing word embeddings, ...)
- Neural word alignment (Blocks/Theano)
- ...

Project links
--------------

- Issue tracker: http://github.com/ucam-smt/sgnmt/issues
- Source code: http://github.com/ucam-smt/sgnmt

Contributors
------------

- Felix Stahlberg, University of Cambridge
- Eva Hasler, SDL Research
- Danielle Saunders, University of Cambridge

License
---------

The project is licensed under the Apache 2 license.

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`

