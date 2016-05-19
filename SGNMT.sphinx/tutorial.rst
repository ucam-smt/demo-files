
.. _tutorial-label:

Tutorial
========

.. warning:: 

      This tutorial is currently under development!

This tutorial describes common use cases for SGNMT. Please
download the `WMT'15 tutorial data <https://www.repository.cam.ac.uk/#will-be-available-soon>`_ archive
and extract it::

  $ wget http://example.org/
  $ tar xzf tutorial-ende-wmt15.tar.gz
  $ cd tutorial-ende-wmt15

This tarball contains NMT model files and translation lattices for replicating some of our results on the 
WMT'15 test set (English-German) in our `ACL 2016 paper <http://arxiv.org/abs/1605.04569>`_. The
directory structure is as follows:

* *./data/* contains the source and target sentences for news-test2015 and word maps.
* *./train/* contains the NMT model file ``params.npz``.
* *./train2/* contains a second NMT model for ensembling.
* *./lats/* contains the Hiero translation lattices.
* *./scripts/* contains helper scripts for creating lattice directories or applying word maps.

This structure is indended to be used as starting point for your own experiments.

The `ucam-smt tutorial <http://ucam-smt.github.io/tutorial/nmt.html>`_ explains how to generate translation lattices
for SGNMT in general.
