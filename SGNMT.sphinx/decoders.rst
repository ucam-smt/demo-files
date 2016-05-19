Decoders
==========================

Decoders are search strategies for traversing the search space which is spanned by the predictors.
Decoders are specified using the ``--decoder`` arguments.

Available decoders
----------------------

* **greedy**: Greedy decoding (similar to beam=1) 

  Options: no options
* **beam**: Beam search like in Bahdanau et al, 2015 

  Options: ``beam``, ``early_stopping``
* **dfs**: Depth-first search. This should be used for exact decoding or the complete enumeration of the search space, 
  but it cannot be used if the search space is too large (like for unrestricted NMT) as it performs exhaustive search. 
  If you have not only negative predictor scores, set ``--early_stopping`` to false. 

  Options: ``max_node_expansions``, ``early_stopping``
* **restarting**: Like DFS but with better admissible pruning behavior. 

  Options: ``max_node_expansions``
* **astar**: A* search. The heuristic function is configured using the ``--heuristics options``. 

  Options: ``beam``, ``nbest``, ``early_stopping``
* **vanilla**: Original blocks beam decoder. This bypasses the predictor framework and directly performs pure NMT beam 
  decoding on the GPU. Use this when you do pure NMT decoding as this is usually faster then using a single nmt predictor 
  as the search can be parallelized on the GPU.

  Options: ``beam_size``

Detailed descriptions are available below in the modules.

Relevant modules
-------------------

cam.sgnmt.decoding.decoder module
****************************************

.. automodule:: cam.sgnmt.decoding.decoder
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

cam.sgnmt.decoding.heuristics module
****************************************

.. automodule:: cam.sgnmt.decoding.heuristics
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
