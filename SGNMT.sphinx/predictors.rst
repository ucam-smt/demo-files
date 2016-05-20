Predictors
============================

Predictors are scoring modules which define a distribution over target words given the history and some side information like the source sentence. 
If vocabulary sizes differ among predictors, we fill in gaps with predictor UNK scores. 

Predictors are specified using the ``--predictors`` and ``--predictor_weights`` arguments, e.g.::

  $ python decode.py --predictors nmt,fst,nplm --predictor_weights 0.7,0.1,0.2 ...

See the :ref:`tutorial-label` page for examples how to use predictors for decoding.

Available predictors
----------------------

The following predictors are available:

* **nmt**: neural machine translation predictor. 

  Options: see the NMT model configurations plus ``proto``, ``nmt_model_selector``, ``cache_nmt_posteriors``. 
* **srilm**: n-gram language model. 

  Options: ``srilm_path``, ``srilm_order``
* **nplm**: neural n-gram language model (NPLM). 

  Options: ``nplm_path``, ``normalize_nplm_probs`` 
* **forced**: Forced decoding with one reference 

  Options: ``trg_test`` 
* **forcedlst**: Forced decoding with a Moses n-best list (n-best list rescoring) 

  Options: ``trg_test``, ``forcedlst_sparse_feat``, ``use_nbest_weights`` 
* **fst**: Deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``add_fst_bos_to_eos_weight`` 
* **nfst**: Non-deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``add_fst_bos_to_eos_weight``
* **rtn**: Recurrent transition networks as created by HiFST with late expansion. 

  Options: ``rtn_path``, ``use_rtn_weights``, ``minimize_rtns``, ``remove_epsilon_in_rtns``, ``normalize_rtn_weights``
* **lrhiero**: Direct Hiero (left-to-right Hiero). This is a EXPERIMENTAL implementation of LRHiero. 

  Options: ``rules_path``, ``grammar_feature_weights``, ``use_grammar_weights``
* **wc**: Number of words feature. 

  Options: no options. 
* **length**: Target sentence length model Options: 

  ``src_test_raw``, ``length_model_weights``, ``use_length_point_probs`` 

All predictors can be combined with one or more wrapper predictors by adding the wrapper name separated by a _ symbol. Following wrappers are available: 

* **idxmap**: Add this wrapper to predictors which use an alternative word map. 
  Options: ``src_idxmap``, ``trg_idxmap`` 

Note that you can use multiple instances of the same predictor. For example, 'nmt,nmt,nmt' can be used for ensembling three NMT systems. 
You can often override parts of the predictor configurations for subsequent predictors by adding the predictor number (e.g. see ``--nmt_config2`` or ``--fst_path2``)

Detailed descriptions are available below in the modules.

Predictor modules
-------------------

cam.sgnmt.predictors.automata module
****************************************

.. automodule:: cam.sgnmt.predictors.automata
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.blocks_neural module
*****************************************************

.. automodule:: cam.sgnmt.predictors.blocks_neural
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.forced module
*****************************************************

.. automodule:: cam.sgnmt.predictors.forced
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.grammar module
*****************************************************

.. automodule:: cam.sgnmt.predictors.grammar
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.length module
*****************************************************

.. automodule:: cam.sgnmt.predictors.length
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.misc module
*****************************************************

.. automodule:: cam.sgnmt.predictors.misc
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.ngram module
*****************************************************

.. automodule:: cam.sgnmt.predictors.ngram
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.nnlm module
*****************************************************

.. automodule:: cam.sgnmt.predictors.nnlm
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:


Module contents
*****************************************************

.. automodule:: cam.sgnmt.predictors
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:
