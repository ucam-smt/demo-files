Neural Machine Translation {#nmt}
=================================

This section describes how to prepare lattices and RTNs produced by HiFST for
our neural machine translation (NMT) tool
[SGNMT](http://ucam-smt.github.io/sgnmt/html/) 
[\ref Stahlberg2016] which is an extension of the NMT implementation in the 
[Blocks](http://blocks.readthedocs.io/en/latest/) 
framework. SGNMT supports lattice, RTN, and n-best rescoring with single
or ensembled NMT, integration of language models and much more. Examples can
be found on the [SGNMT tutorial page](http://ucam-smt.github.io/sgnmt/html/tutorial.html).


\section prepare_lattices Preparing Lattices for SGNMT

Translation lattices produced by HiFST use the **lexicographic semiring  of two tropical weights** [\ref Roark2011] \(see \ref basic_scores\).
However, SGNMT requires lattices with standard arcs. HiFST provides the `lexmap` tool to convert lexicographic to standard arcs. Additionally,
we usually apply epsilon removal, determinisation, minimisation, and weight pushing to the translation lattices before passing them
through to SGNMT [\ref Stahlberg2016]. We also map HiFST special symbols to epsilon in order to remove them from the final lattices.
The full pipeline looks like that:

     > cat hifst_special_symbol_to_eps_map
     999999991 0
     999999992 0
     999999993 0
     999999994 0
     999999995 0
     999999996 0
     999999997 0
     999999998 0
     999999999 0
     100000000 0
     > zcat output/exp.baseline/LATS/1.fst.gz | lexmap.${TGTBINMK}.bin --action=lex2std | \
                                                fstrelabel -relabel_ipairs=hifst_special_symbol_to_eps_map -relabel_opairs=hifst_special_symbol_to_eps_map | \
                                                fstrmepsilon | \
                                                fstdeterminize | \
                                                fstminimize | \
                                                fstmap -map_type=to_log | \
                                                fstpush --push_weights > output/exp.baseline/LATS.sgnmt/1.fst
     
The `scripts/` directory in the [SGNMT tutorial data](http://ucam-smt.github.io/sgnmt/html/tutorial.html) contains the script
`create_fst_directory.sh` which prepares a complete HiFST lattice directory for SGNMT.

Note that for large lattices, determinisation is not possible because \ref OpenFst [Determinize](http://www.openfst.org/twiki/bin/view/FST/DeterminizeDoc)
requires too much memory. In this case, you can skip epsilon removal, determinisation, and minimisation, and use SGNMT's 
[nfst predictor](http://ucam-smt.github.io/sgnmt/html/predictors.html).

\section prepare_rtns Preparing RTNs for SGNMT

SGNMT supports decoding on the search space spanned by an RTN. Arc expansion (i.e. replacing a non-terminal arc with a FST) is done
on-the-fly only if the search algorithm arrives at this arc (late expansion). Like lattices, RTNs need to be converted from the
lexicographic semiring using the `lexmap` tool, but without changing the directory structure.
The `scripts/` directory in the [SGNMT tutorial data](http://ucam-smt.github.io/sgnmt/html/tutorial.html) contains the script
`create_rtn_directory.sh` to do that.


