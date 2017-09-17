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

* **nmt**: neural machine translation predictor. Requires Blocks/Theano or TensorFlow.

  Options: ``nmt_config``, ``nmt_path``, ``nmt_model_selector``, ``cache_nmt_posteriors``, ``nmt_engine`` 
* **t2t**: Predictor for tensor2tensor models. Requires Tensor2Tensor.

  Options: ``t2t_usr_dir``, ``t2t_model``, ``t2t_problem``, ``t2t_hparams_set``, ``t2t_checkpoint_dir``, ``t2t_src_vocab_size``, ``t2t_trg_vocab_size``
* **srilm**: n-gram language model. Requires swig-srilm.

  Options: ``srilm_path``, ``srilm_order``
* **nplm**: neural n-gram language model. Requires nplm.

  Options: ``nplm_path``, ``normalize_nplm_probs`` 
* **rnnlm**: RNN language model following Zaremba et al. (2014). Requires TensorFlow. 

  Options: ``rnnlm_config, rnnlm_path`` 
* **forced**: Forced decoding with one reference 

  Options: ``trg_test`` 
* **forcedlst**: Forced decoding with a Moses n-best list (n-best list rescoring) 

  Options: ``trg_test``, ``forcedlst_sparse_feat``, ``use_nbest_weights`` 
* **bow**: Forced decoding with one bag-of-words ref.

  Options: ``trg_test``, ``heuristic_scores_file``, ``bow_heuristic_strategies``, ``bow_accept_subsets``, ``bow_accept_duplicates``, ``bow_equivalence_vocab_size``
* **bowsearch**: Forced decoding with one bag-of-words ref.

  Options: ``hypo_recombination``, ``trg_test``, ``heuristic_scores_file``, ``bow_heuristic_strategies``, ``bow_accept_subsets``, ``bow_accept_duplicates``, ``bow_equivalence_vocab_size``
* **fst**: Deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``fst_skip_bos_weight`` 
* **nfst**: Non-deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``fst_skip_bos_weight``
* **rtn**: Recurrent transition networks as created by HiFST with late expansion. 

  Options: ``rtn_path``, ``use_rtn_weights``, ``minimize_rtns``, ``remove_epsilon_in_rtns``, ``normalize_rtn_weights``
* **lrhiero**: Direct Hiero (left-to-right Hiero). This is a EXPERIMENTAL implementation of LRHiero. 

  Options: ``rules_path``, ``grammar_feature_weights``, ``use_grammar_weights``
* **wc**: Number of words feature. 

  Options: ``wc_word``
* **unkc**: Poisson model for number of UNKs.

  Options: ``unk_count_lambdas``
* **ngramc**: For using MBR n-gram posteriors.

  Options: ``ngramc_path``, ``ngramc_order``
* **length**: Target sentence length model. 

  Options: ``src_test_raw``, ``length_model_weights``, ``use_length_point_probs`` 
* **extlength**: External target sentence lengths. 

  Options: ``extlength_path`` 

All predictors can be combined with one or more wrapper predictors by adding the wrapper name separated by a _ symbol. Following wrappers are available: 

* **idxmap**: Add this wrapper to predictors which use an alternative word map. 

  Options: ``src_idxmap``, ``trg_idxmap`` 
* **altsrc**: This wrapper loads source sentences from an alternative source.

  Options: ``altsrc_test`` 
* **unkvocab**: This wrapper explicitly excludes matching word indices higher than trg_vocab_size with UNK scores.

  Options: ``trg_vocab_size``
* **fsttok**: Uses an FST to transduce SGNMT tokens to predictor tokens.

  Options: ``fsttok_path``, ``fsttok_max_pending_score``, ``fst_unk_id``
* **word2char**: Wraps word-level predictors when SGNMT is running on character level.

  Options: ``word2char_map`` 

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

cam.sgnmt.predictors.blocks_nmt module
****************************************

.. automodule:: cam.sgnmt.predictors.blocks_nmt
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.bow module
****************************************

.. automodule:: cam.sgnmt.predictors.bow
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.core module
****************************************

.. automodule:: cam.sgnmt.predictors.core
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.ffnnlm module
****************************************

.. automodule:: cam.sgnmt.predictors.ffnnlm
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.forced module
****************************************

.. automodule:: cam.sgnmt.predictors.forced
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.grammar module
****************************************

.. automodule:: cam.sgnmt.predictors.grammar
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.length module
****************************************

.. automodule:: cam.sgnmt.predictors.length
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.misc module
****************************************

.. automodule:: cam.sgnmt.predictors.misc
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.ngram module
****************************************

.. automodule:: cam.sgnmt.predictors.ngram
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.tf_nmt module
****************************************

.. automodule:: cam.sgnmt.predictors.tf_nmt
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.tf_rnnlm module
****************************************

.. automodule:: cam.sgnmt.predictors.tf_rnnlm
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.tf_t2t module
****************************************

.. automodule:: cam.sgnmt.predictors.tf_t2t
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.tokenization module
****************************************

.. automodule:: cam.sgnmt.predictors.tokenization
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:


Module contents
****************************************

.. automodule:: cam.sgnmt.predictors
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

