RTNs and PDAs {#pda}
=====

As already discussed with respect to \ref lpruning, HiFST generates an
initial representation of the space of translation in the form of an
RTN, which is then transformed either to WFSAs or to PDAs using the
\ref OpenFst
[Replace](http://openfst.org/twiki/bin/view/FST/ReplaceDoc) operation
prior to application of the language model.  This leads to two
alternative translation pipelines starting from the RTNs (see Figure 2
\ref Allauzen2014).  Both piplines start with RTNs containing
translation grammar scores alone, however in the HiPDT pipeline, WFSAs
are not created until after the LM is applied to the translations:

   - HiFST: Translation via WFSAs
     - RTNs are transformed to WFSAs by the OpenFst [fstreplace](http://openfst.org/twiki/bin/view/FST/ReplaceDoc) operation
     - WFSAs are intersected with LMs 
     - The WFSA is pruned under the combined translation grammar and LM scores
   - HiPDT: Translation via PDTs
     - RTNs are transformed to PDAs via the OpenFst [pdtreplace](http://www.openfst.org/twiki/bin/view/FST/FstExtensions) operation
     - PDAs are intersected with the LMs 
     - WFSAs are generated from PDAs via pruned Expansion
     - The WFSA is further pruned under the combined translation grammar and LM scores

In HiPDT, the RTN at the top-most cell of the CYK grid is converted
into a PDA (via the Replace operation in the OpenFst Extensions) and
efficiently composed with a language model to produce another PDA. To
obtain the final output FSA, the PDA is expanded to an FSA either
entirely (if memory is sufficient and the language model is small
enough) or via pruned expansion (for larger language models). This is
useful in exploring large and complex translation grammars where HiFST
requires a lot of local pruning. However, it requires the language
model to be 'small' (for example, entropy-pruned as in [\ref
Iglesias2011, \ref Allauzen2014]). Therefore, we then typically
rescore the pruned output FSA with a stronger language model.

Both the HiFST and the HiPDT pipelines are implemented by the HiFST program, and are run here with the Shallow-1 translation grammar and the 4-gram language model:

    > hifst.${TGTBINMK}.bin --config=configs/CF.baseline
    > hifst.${TGTBINMK}.bin --config=configs/CF.baseline.pdt

Translation via PDTs uses more memory (as described in \ref Allauzen2014), both otherwise the outputs should be identical:

    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -u --input=output/exp.baseline/LATS/1.fst.gz --label-map=wmaps/wmt13.en.wmap -w
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999,-19.4512

    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -u --input=output/exp.baseline.pdt/LATS/1.fst.gz --label-map=wmaps/wmt13.en.wmap -w
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999,-19.4512


The following two sections uses the OpenFST command line tools to show the details of the HiFST and the HiPDT pipelines.
   - Using HiFST to generate RTNs is described in section \ref pda_rtns
   - The HiFST pipeline is described in section \ref pda_rtn_expansion
   - The HiPDT pipeline is described in section \ref pda_pda_expand

\section pda_rtns Generating RTNs

Translation can be re-run, but with added instructions to save the RTNs to disk:

    > hifst.${TGTBINMK}.bin --config=configs/CF.baseline --hifst.writertn=output/exp.baseline/rtn/?/%%rtn_label%%.fst --grammar.storentorder=output/exp.baseline/rtn/ntmap  --hifst.rtnopt=yes &> log/log.baseline.rtn

The RTNs are written to the directory `output/exp.baseline/rtn/*` as

    > ls output/exp.baseline/rtn/1/
    1001000009.fst  1003002003.fst 1003003002.fst   1003005001.fst 1003006001.fst   1004001001.fst  1004003000.fst  1004004001.fst  1004006000.fst
    1003002001.fst  1003002004.fst 1003004001.fst   1003005002.fst 1003007001.fst   1004002000.fst  1004003001.fst  1004005000.fst  1004007000.fst
    1003002002.fst  1003003001.fst 1003004002.fst   1003005003.fst 1004001000.fst   1004002001.fst  1004004000.fst  1004005001.fst  1004008000.fst

and the non-terminal mapping is written to output/exp.baseline/rtn/ntmap :

    > cat output/exp.baseline/rtn/ntmap
    S   1
    D   2
    X   3
    V   4

Each RTN name is of the form 1ABC.fst , where A, B, and C are 3-digit strings.
   - A is the numerical code for a non-terminal in the grammar; in this case, 001 corresponds to S.  
   - B indicates a position in the source sentence: 0 <= B < I, where I is the source sentence length
   - C indicates the offset to the end of a span, 0 <= C and B+C < I
   - The automata 1ABC.fst corresponds to T_(A,B,B+C) in the formulation of \ref lpruning

In this example, the automata 1003002002.fst contains all derivations headed by X, the third non-terminal, and spanning source positions 2 to 4 (=2+2).

The root automata is 1001000009.fst, since A=001 (the S non-terminal),
B=0 (the first source position), and C=9 (the sentence has 10 words).

The automata is a representation of all possible translations of the
source sentence under this grammar, as can be seen by printing its paths (here the first 5):

    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -u --nbest=5 --input=output/exp.baseline/rtn/1/1001000009.fst 
    ...
    1 1004001000 135 20 103 1004004000 1004005000 1004006000 1004007000 1004008000 2 
    1 1004001000 135 20 103 1004004000 1004005000 1003006001 1004008000 2 
    1 1004001000 135 20 103 1004004000 1003005001 1004007000 1004008000 2 
    1 1004001000 135 20 103 1003004001 1004006000 1004007000 1004008000 2 
    1 1004001000 135 20 103 1004004000 1004005000 1004006000 1003007001 2 
    ...

As can be seen, the symbols are a mix of target language symbols (1,135,20,102,2,...) and pointers to other automata (1004004000, 1004005000, ...).
Conversion of the RTN is done by recursive substitution of these symbols by the FSTs to which they point, starting from the root automata.

\section pda_rtn_expansion Translation by RTN Expansion to WFSAs

The `fstreplace` command is used to expand the collection of WFSAs comprising the RTN into a single equivalent WFSA.

     > fstreplace | head -n 3
     Recursively replaces FST arcs with other FST(s).

     Usage: fstreplace root.fst rootlabel [rule1.fst label1 ...] [out.fst]

Note that the root FST and root label are always of the form 1001000C, where C = I - 1 , where I is the source sentence length.
HiFST uses the same names for rules and labels,  so we get get the filenames and labels in the right form by, e.g.

     > ls output/exp.baseline/rtn/1/1*.fst | sed 's,\(.*\)/\(.*\).fst,\1/\2.fst \2,' > tmp/script.replace
     > head -2 tmp/script.replace
     output/exp.baseline/rtn/1/1001000009.fst 1001000009
     output/exp.baseline/rtn/1/1003002001.fst 1003002001

The following will expand the RTN into an FSA:

     > fstreplace `cat tmp/script.replace` > output/exp.baseline/rtn/1/T.fst

The WFSA `output/exp.baseline/rtn/1/T.fst` is the replacement of the RTN that was generated in translation.  It is a transducer: the input maintains the pointers to the automata used in translating each source span; the output is the corresponding translation

     > fstproject output/exp.baseline/rtn/1/T.fst | fstrmepsilon | printstrings.${TGTBINMK}.bin --semiring=lexstdarc -u --nbest=5 -w
     ...
     1 1004001000 50 6 3 1003002002 1004002001 135 20 103 3 34 245 1004005000 4 1004006000 33 31 3 154 82 1145 1003007001 1004007000 3 425 6 23899 2       -29.123,-29.123
     1 1004001000 50 6 3 1003002002 1004002001 135 20 103 3 34 245 1003005001 4 1004006000 33 31 3 154 82 1145 1003007001 1004007000 3 425 6 23899 2       -29.0996,-29.0996
     1 1004001000 50 6 3 1003002002 1004002001 135 20 103 3 34 245 1004005000 4 1004006000 33 31 3 154 82 1145 1004007000 3 425 6 1004008000 23899 2       -29.0801,-29.0801
     1 1004001000 50 6 3 1003002002 1004002001 135 20 103 3 34 245 1003005001 4 1004006000 33 31 3 154 82 1145 1004007000 3 425 6 1004008000 23899 2       -29.0566,-29.0566
     1 1004001000 50 6 3 1003002002 1004002001 135 20 103 3 34 245 1004005000 4 1004006000 33 31 3 154 82 1145 1003007001 425 6 3 1004008000 23899 2       -29.0537,-29.0537
     ...

     > fstproject --project_output output/exp.baseline/rtn/1/T.fst | fstrmepsilon | printstrings.${TGTBINMK}.bin --semiring=lexstdarc -u --nbest=5 -w
     ...
     1 50 6 3 135 20 103 3 34 245 4 33 31 3 154 82 1145 3 425 6 23899 2      -29.123,-29.123
     1 50 6 3 135 20 103 3 34 245 4 33 31 3 154 82 1145 425 6 3 23899 2      -29.0537,-29.0537
     1 50 6 3 135 20 103 3 34 245 4 3 33 31 3 154 82 1145 3 425 6 23899 2    -29.0518,-29.0518
     1 50 6 3 135 20 103 3 34 245 4 3 33 31 3 154 82 1145 425 6 3 23899 2    -28.9824,-28.9824
     1 3 50 6 135 20 103 3 34 245 4 33 31 3 154 82 1145 3 425 6 23899 2      -28.9463,-28.9463


\subsection rtn_lm_app Applying the LM to the WFSA

The `applylm` tool can be used to apply the baseline 4-gram language model to T via composition.  This generates a new WFSA containing both grammar and language model scores:

- Input
   - M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap : n-gram LM
   - output/exp.baseline/rtn/1/T.fst : WFSA containing translation grammar scores
- Output
   - output/exp.baseline/rtn/1/TG.fst : WFSA containing translation grammar and LM scores

The output is written in the form of a transducer, with the RTN labels as the input symbols and the target language words on the output symbols:

    > applylm.${TGTBINMK}.bin --lm.load=M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap --semiring=lexstdarc --lattice.load=output/exp.baseline/rtn/1/T.fst --lattice.store=output/exp.baseline/rtn/1/TG.fst
    > fstshortestpath output/exp.baseline/rtn/1/TG.fst | fstrmepsilon | fsttopsort | fstprint | head
    0     1     1     1   -2.68554688,-2.68554688
    1     2 1004001000     0   
    2     3    50    50   6.39422989,-2.88476562
    3     4 1003002002     0   1.53515625,1.53515625
    4     5   135   135   -0.098549366,-6.18554688
    5     6    20    20   0.961314559,0
    6     7   103   103   4.64596272,0
    7     8     3     3   0.961314559,0
    8     9 1004004000     0   
    9    10   245   245   5.13327551,-0.48828125


To see the translation alone, we project to the output symbols:


    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap --print-output-labels --input=output/exp.baseline/rtn/1/TG.fst
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999,-19.4512


which should agree with the previously generated contents of output/exp.baseline/LATS/1.fst.gz produced by the baseline system:

    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap --input=output/exp.baseline/LATS/1.fst.gz
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999,-19.4512


\section pda_pda_expand Translation by PDA Pruned Expansion 

(Note, as of July 2015: The OpenFST PDT command line operations do not work well with our lexicographic library, so the standard tropical semirring must be used in this example. This makes the example slightly more complex than it actually is in practice.)

**Step 0.** Dump the RTN under the full translation grammar, as described in \ref  pda_rtns

    > hifst.${TGTBINMK}.bin --config=configs/CF.baseline --hifst.writertn=output/exp.baseline/rtn/?/%%rtn_label%%.fst --grammar.storentorder=output/exp.baseline/rtn/ntmap  --hifst.rtnopt=yes &> log/log.baseline.rtn

**Note** that that translations under the grammar `G/rules.shallow.gz` and LM `M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap` are written to the FST `output/exp.baseline/LATS/1.fst.gz` in the usual way.   However the RTN is written to the directory `output/exp.baseline/rtn/1/` *without* the language model score.

**Step 2.** Use `lexmap` to transform the RTN files `output/exp.baseline/rtn/1/100*.fst` into in the standard tropical semiring (`output/exp.baseline/rtn/1/100*.fst-tp`):

    > for f in output/exp.baseline/rtn/1/100*.fst; do lexmap.${TGTBINMK}.bin --action=lex2std --input=$f > $f-tp; done;

**Step 3.** Transform the RTN into a PDT:

    > ls output/exp.baseline/rtn/1/1*.fst-tp | sed 's,\(.*\)/\(.*\).fst-tp,\1/\2.fst-tp \2,' > output/exp.baseline/rtn/1/script.replace
    > pdtreplace --pdt_parentheses=output/exp.baseline/rtn/1/parens.txt `cat output/exp.baseline/rtn/1/script.replace` > output/exp.baseline/rtn/1/T.pdt

where the `pdt_parentheses' option indicates that the open/close parentheses symbols are to be stored into a file; note that this file varies with the translations. This is used later in order to expand the PDA to an FSA.

**Step 4.** Compose the PDA with the weak language model. This is done via the standard composition algorithm, but making sure that open/close parentheses symbols are treated as epsilons by the composition algorithm. To accomplish this, their respective output symbols need to be relabelled to 0 before applying the LM:

    # relabel
    > tr '\t' '\n' < output/exp.baseline/rtn/1/parens.txt | sed 's/$/\t0/' > output/exp.baseline/rtn/1/parens-to-epsilon.txt 
    > fstrelabel -relabel_opairs=output/exp.baseline/rtn/1//parens-to-epsilon.txt output/exp.baseline/rtn/1/T.pdt > output/exp.baseline/rtn/1/Tb.pdt
    # apply LMs
    > applylm.${TGTBINMK}.bin --lm.load=M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap --lattice.load=output/exp.baseline/rtn/1/Tb.pdt --lattice.store=output/exp.baseline/rtn/1/TG.pdt 

**Step 5.** Expand the resulting PDT into an FSA while applying a pruning weight of 9:

    > fstproject output/exp.baseline/rtn/1/TG.pdt | pdtexpand --pdt_parentheses=output/exp.baseline/rtn/1/parens.txt --weight=9 > output/exp.baseline/rtn/1/TG.fst

The translation result following pruned expansion of the PDT should agree with the translation hypothesis produced directly by HiFST:

    > printstrings.${TGTBINMK}.bin --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap --input=output/exp.baseline/LATS/1.fst.gz
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999,-19.4512
    ...

    > printstrings.${TGTBINMK}.bin -w -m wmaps/wmt13.en.wmap --input=output/exp.baseline/rtn/1/TG.fst
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  42.6999
    ...

**Step 6. (optional)** Remove the pruned LM and apply the full LM.    The language model `M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap` is a heavily pruned version of `M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap`.  **Note** that the larger LM will have to be installed and uncompressed as described in \ref tutorial_install.

    # remove the pruned LM
    # since .../1/TG.fst is not lexicographic form, we subtract the pruned lm scores and write a version of the FST with translation scores only 
    > applylm.${TGTBINMK}.bin --lm.load=M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap --lm.featureweights=-1 --lattice.load=output/exp.baseline/rtn/1/TG.fst --lattice.store=output/exp.baseline/rtn/1/TG-nolm.fst  
    # apply the strong LM
    > applylm.${TGTBINMK}.bin --lm.load=M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap --lattice.load=output/exp.baseline/rtn/1/TG-nolm.fst --lattice.store=output/exp.baseline/rtn/1/TG-final.fst


The final FSA that results from this process (`output/exp.baseline/rtn/1/TG-final.fst`) contains translations under the Hiero grammar with the full, unpruned LM:

    > printstrings.${TGTBINMK}.bin -w -m wmaps/wmt13.en.wmap --input=output/exp.baseline/rtn/1/TG-final.fst
    ...
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>  43.093

The overall score changes, due to the bigger LM,  but the top hypothesis is unchanged.
