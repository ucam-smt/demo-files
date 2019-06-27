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

SGNMT is compatible with the following NMT toolkits:

-  `Tensor2Tensor <https://github.com/tensorflow/tensor2tensor>`_ (`TensorFlow <https://www.tensorflow.org/>`_)
-  `fairseq <https://github.com/pytorch/fairseq>`_ (`PyTorch <https://pytorch.org/>`_)

Old SGNMT versions (0.x) are compatible with:

- `(extended) TF seq2seq tutorial <https://github.com/ehasler/tensorflow>`_ (`TensorFlow <https://www.tensorflow.org/>`_)
- `Blocks <http://blocks.readthedocs.io/en/latest/>`_ (`Theano <http://deeplearning.net/software/theano/>`_)

Contents
-------------
.. toctree::
   :maxdepth: 1

   setup
   tutorial
   tutorial_pytorch
   adding_components
   bea19_gec
   tutorial_blocks
   command_line
   predictors
   decoders
   examples
   faq
   publications
   All modules <cam.sgnmt>

Features
------------

- Syntactically guided neural machine translation (NMT lattice rescoring)
- Target-side syntax for NMT
- n-best list rescoring with NMT
- Integrating external n-gram posterior probabilities used in MBR
- Ensemble NMT decoding
- Forced NMT decoding
- Integrating language models
- Different search algorithms (beam, A*, depth first search, greedy...)
- Target sentence length modelling
- Bag2Sequence models and decoding algorithms
- Joint decoding with word- and subword/character-level models
- Hypothesis recombination
- Heuristic search
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

