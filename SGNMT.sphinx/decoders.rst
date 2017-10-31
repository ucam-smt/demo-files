Decoders
==========================

Decoders are search strategies for traversing the search space which is spanned by the predictors.
Decoders are specified using the ``--decoder`` arguments.

Available decoders
----------------------

* **greedy**: Greedy decoding (similar to beam=1) 
* **beam**: Beam search like in Bahdanau et al, 2015 .
* **sepbeam**: Associates predictors with hypos in beam search and applies only one predictor instead of all for hypo expansion.
* **syncbeam**: Beam search which compares after consuming a special synchronization symbol instead of after each iteration.
* **multisegbeam**: Beam search with multiple segmentations. 
* **dfs**: Depth-first search. This should be used for exact decoding or the complete enumeration of the search space. 
  but it cannot be used if the search space is too large (like for unrestricted NMT) as it performs exhaustive search. 
  If you have not only negative predictor scores, set ``--early_stopping`` to false. 
* **restarting**: Like DFS but with better admissible pruning behavior. 
* **astar**: A* search. The heuristic function is configured using the ``--heuristics options``. 
* **bucket**: Works best for bag problems. Maintains buckets for each hypo length and extends a hypo in a bucket by one before selecting the next bucket.
* **flip**: This decoder works only for bag problems. It traverses the search space by switching two words in the hypothesis. Do not use bow predictor.
* **bow**: Restarting decoder optimized for bag-of-words problems.
* **bigramgreedy**: Works best for bag problems. Collects bigram statistics and constructs hypos to score by greedily selecting high scoring bigrams. Do not use bow predictor with this search strategy.
* **vanilla**: Original Blocks beam decoder. This bypasses the predictor framework and directly performs pure NMT beam 
  decoding on the GPU. Use this when you do pure NMT decoding as this is usually faster then using a single nmt predictor 
  as the search can be parallelized on the GPU.

Detailed descriptions are available below in the modules.

Relevant modules
-------------------

cam.sgnmt.decoding.astar module
****************************************

.. automodule:: cam.sgnmt.decoding.astar
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.beam module
****************************************

.. automodule:: cam.sgnmt.decoding.beam
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.bigramgreedy module
****************************************

.. automodule:: cam.sgnmt.decoding.bigramgreedy
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.bow module
****************************************

.. automodule:: cam.sgnmt.decoding.bow
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.bucket module
****************************************

.. automodule:: cam.sgnmt.decoding.bucket
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.core module
****************************************

.. automodule:: cam.sgnmt.decoding.core
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.decoder module
****************************************

.. automodule:: cam.sgnmt.decoding.decoder
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.dfs module
****************************************

.. automodule:: cam.sgnmt.decoding.dfs
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.flip module
****************************************

.. automodule:: cam.sgnmt.decoding.flip
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.greedy module
****************************************

.. automodule:: cam.sgnmt.decoding.greedy
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.heuristics module
****************************************

.. automodule:: cam.sgnmt.decoding.heuristics
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.multisegbeam module
****************************************

.. automodule:: cam.sgnmt.decoding.multisegbeam
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.restarting module
****************************************

.. automodule:: cam.sgnmt.decoding.restarting
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.sepbeam module
****************************************

.. automodule:: cam.sgnmt.decoding.sepbeam
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.decoding.syncbeam module
****************************************

.. automodule:: cam.sgnmt.decoding.syncbeam
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

Module contents
****************************************

.. automodule:: cam.sgnmt.decoding
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

