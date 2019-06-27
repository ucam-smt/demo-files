
Common issues
===========================

.. toctree::
   :maxdepth: 1

.. note:: 

      If you don't find an answer here, check out the `issue tracker on Github <http://github.com/ucam-smt/sgnmt/issues>`_.


Config files are ignored
-------------------------

Install PyYAML with ``pip install pyyaml``.

Beam decoder with beam=12 does not create 12-best lists
---------------------------------------------------------

The beam decoder stops when the best scoring hypothesis ends with the end-of-sentence symbol. Therefore, n-best lists 
do not contain hypotheses longer than the best hypothesis. If you want to create full n-best lists, use
``--early_stopping false``. Thereby, the decoding does not stop until all active hypotheses end with the end-of-sentence symbol.

UnicodeDecodeError: 'ascii' codec can't decode byte...
------------------------------------------------------

Python is not properly set up to read your word maps or source sentence files. Make sure that your Anaconda environment and your 
locals are set up correctly (e.g. ``LC_ALL`` points to a value installed on your system). Consider processing indexed sentences
(default ``preprocessing`` and ``postprocessing`` options) and handle unicode separately.

Decoding continues after the end-of-sentence symbol
---------------------------------------------------

Double-check that the reserved IDs in your predictor are consistent with SGNMT. You can change the
reserved IDs used by SGNMT with the ``indexing_scheme`` parameter, or mask predictors with their
own reserved IDs with the ``idxmap`` predictor wrapper.

'No complete hypothesis found' when combining models with different tokenizations
---------------------------------------------------------------------------------

Make sure that all your word maps use the standard names for reserved tokens (``<eps>``, ``<s>``, ``</s>``). Also, 
double-check that your ``indexing_scheme`` parameter is consistent with the word maps and the indexing schemes 
in your models.

'int' object is not callable (fst, nfst, rtn predictors)
--------------------------------------------------------

You are likely to use an outdated OpenFST version. The minimum required version is 1.5.4.

tropicalsparsetuple-arc.so: cannot open shared object file
-----------------------------------------------------------

You are using the *fst* output format to create translation lattices with sparse tuple arcs, but your OpenFST does not support
the arc type tropicalsparsetuple. Check out the `ucam-smt tutorial <http://ucam-smt.github.io/tutorial/build.html>`_ for more
information.

