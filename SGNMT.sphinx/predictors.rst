Predictors
============================

Predictors are scoring modules which define a distribution over target words given the history and some side information like the source sentence. 
If vocabulary sizes differ among predictors, we fill in gaps with predictor UNK scores. 

Note that you can use multiple instances of the same predictor. For example, 't2t,t2t,t2t' can be used for ensembling three T2T models. 
You can often override parts of the predictor configurations for subsequent predictors by adding the predictor number (e.g. see ``--t2t_checkpoint_dir2`` or ``--fst_path2``)

Main predictors
----------------------

The following main predictors are available. The installation of additional (optional) software required by some of the predictors is described on the :ref:`setup-label` page.

For a more detailed description of the predictors, search for the name of the predictor in the :ref:`predictor-modules-label` section.

* **t2t**: Predictor for tensor2tensor models. Requires Tensor2Tensor.

  Options: ``t2t_usr_dir``, ``t2t_model``, ``t2t_problem``, ``t2t_hparams_set``, ``t2t_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``, ``n_cpu_threads``
* **fairseq**: Predictor for fairseq models. Requires fairseq.

  Options: ``fairseq_path``, ``fairseq_user_dir``, ``fairseq_lang_pair``, ``n_cpu_threads``
* **kenlm**: Count-based n-gram language model in ARPA format. Requires KenLM.

  Options: ``lm_path``
* **forced**: Forced decoding with one reference 

  Options: ``trg_test`` 
* **forcedlst**: Forced decoding with a Moses n-best list (n-best list rescoring) 

  Options: ``trg_test``, ``forcedlst_match_unk``, ``forcedlst_sparse_feat``, ``use_nbest_weights`` 
* **osm**: Constraints output to valid OSM sequences 

  Options: ``osm_type``
* **bow**: Forced decoding with one bag-of-words ref.

  Options: ``trg_test``, ``heuristic_scores_file``, ``bow_heuristic_strategies``, ``bow_accept_subsets``, ``bow_accept_duplicates``, ``pred_trg_vocab_size``
* **fst**: Deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``fst_skip_bos_weight`` 
* **nfst**: Non-deterministic translation lattices 

  Options: ``fst_path``, ``use_fst_weights``, ``normalize_fst_weights``, ``fst_to_log``, ``fst_skip_bos_weight``
* **wc**: Number of words feature. 

  Options: ``wc_word``, ``negative_wc``, ``wc_nonterminal_penalty``, ``syntax_nonterminal_ids``, ``syntax_min_terminal_id``, ``syntax_max_terminal_id``, ``pred_trg_vocab_size``
* **ngramc**: For using MBR n-gram posteriors.

  Options: ``ngramc_path``, ``ngramc_order``

All predictors can be combined with one or more wrapper predictors by adding the wrapper name separated by a _ symbol. Following main wrappers are available: 

* **idxmap**: Add this wrapper to predictors which use an alternative word map. 

  Options: ``src_idxmap``, ``trg_idxmap`` 
* **altsrc**: This wrapper loads source sentences from an alternative source.

  Options: ``altsrc_test`` 
* **fsttok**: Uses an FST to transduce SGNMT tokens to predictor tokens.

  Options: ``fsttok_path``, ``fsttok_max_pending_score``, ``fst_unk_id``


Experimental predictors
------------------------

Experimental predictors are less frequently used but working predictor implementations for special cases.

* **editt2t**: Predictor for searching over t2t models via edit operations. Requires Tensor2Tensor.

  Options: ``t2t_usr_dir``, ``t2t_model``, ``t2t_problem``, ``t2t_hparams_set``, ``t2t_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``, ``trg_test``, ``beam``
* **fertt2t**: Predictor for tensor2tensor models predicting source token fertilities. Requires Tensor2Tensor.

  Options: ``t2t_usr_dir``, ``t2t_model``, ``t2t_problem``, ``t2t_hparams_set``, ``t2t_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``
* **segt2t**: Predictor for tensor2tensor models with ``_seg`` and ``_pos`` features. Requires Tensor2Tensor.

  Options: ``t2t_usr_dir``, ``t2t_model``, ``t2t_problem``, ``t2t_hparams_set``, ``t2t_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``
* **nizza**: Nizza alignment models. Requires Nizza.

  Options: ``nizza_model``, ``nizza_hparams_set``, ``nizza_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``
* **lexnizza**: Uses Nizza lexical scores to check coverage. Requires Nizza.

  Options: ``nizza_model``, ``nizza_hparams_set``, ``nizza_checkpoint_dir``, ``pred_src_vocab_size``, ``pred_trg_vocab_size``, ``lexnizza_alpha``, ``lexnizza_beta``, ``lexnizza_shortlist_strategies``, ``lexnizza_max_shortlist_length``
* **bracket**: Enforces well-formed bracket expressions 

  Options: ``syntax_pop_id`` , ``syntax_max_terminal_id``, ``syntax_max_depth``, ``extlength_path``
* **forcedosm**: Forced alignment with an OSM model

  Options: ``trg_test``
* **rtn**: Recurrent transition networks as created by HiFST with late expansion. 

  Options: ``rtn_path``, ``use_rtn_weights``, ``minimize_rtns``, ``remove_epsilon_in_rtns``, ``normalize_rtn_weights``
* **lrhiero**: Direct Hiero (left-to-right Hiero). This is an EXPERIMENTAL implementation of LRHiero. 

  Options: ``rules_path``, ``grammar_feature_weights``, ``use_grammar_weights``
* **unkc**: Poisson model for number of UNKs.

  Options: ``unk_count_lambdas``, ``pred_trg_vocab_size``
* **length**: Target sentence length model. 

  Options: ``src_test_raw``, ``length_model_weights``, ``use_length_point_probs`` 
* **extlength**: External target sentence lengths. 

  Options: ``extlength_path`` 

Following experimental predictor wrappers are available:

* **glue**: Masks sentence-level predictors when SGNMT runs on the document level.

  Options: 
* **parse**: Internal beam search over a representation which contains some pre-defined non-terminal ids, which should not appear in the output.

  Options: ``parse_tok_grammar``, ``parse_bpe_path``, ``syntax_path``, ``syntax_bpe_path``, ``syntax_word_out``, ``normalize_fst_weights``, ``syntax_norm_alpha``, ``syntax_internal_beam``, ``syntax_max_internal_len``, ``syntax_allow_early_eos``, ``syntax_consume_ooc``, ``syntax_terminal_restrict``, ``syntax_internal_only``, ``syntax_eow_ids``, ``syntax_terminal_ids``
* **rank**: Does not use the scores of the wrapped predictor directly but the rank in the scores table.

  Options: 
* **ngramize**: Extracts n-gram posteriors from a predictor without feedback loop.

  Options: ``min_ngram_order``, ``max_ngram_order``, ``max_len_factor``
* **skipvocab**: Uses internal beam search to skip a subset of the predictor vocabulary.

  Options: ``beam``, ``skipvocab_max_id``, ``skipvocab_stop_size`` 
* **maskvocab**: Hides a subset of the SGNMT vocabulary from the wrapped predictor.

  Options: ``maskvocab_words`` 
* **unkvocab**: This wrapper explicitly excludes matching word indices higher than ``pred_trg_vocab_size`` with UNK scores.

  Options: ``pred_trg_vocab_size``
* **word2char**: Wraps word-level predictors when SGNMT is running on character level.

  Options: ``word2char_map`` 


.. _predictor-modules-label:

Predictor modules
-------------------

Module contents
****************************************

.. automodule:: cam.sgnmt.predictors
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:


cam.sgnmt.predictors.automata module
****************************************

.. automodule:: cam.sgnmt.predictors.automata
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

cam.sgnmt.predictors.parse module
****************************************

.. automodule:: cam.sgnmt.predictors.parse
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.pytorch_fairseq module
*******************************************

.. automodule:: cam.sgnmt.predictors.pytorch_fairseq
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.structure module
****************************************

.. automodule:: cam.sgnmt.predictors.structure
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:

cam.sgnmt.predictors.tf_nizza module
****************************************

.. automodule:: cam.sgnmt.predictors.tf_nizza
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

cam.sgnmt.predictors.vocabulary module
****************************************

.. automodule:: cam.sgnmt.predictors.vocabulary
    :members:
    :undoc-members:
    :show-inheritance:
    :noindex:


