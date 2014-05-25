\page HiPDT
\section pda Push-Down Automata

This HiFST package can also perform decoding using Push-Down Automata (PDA) as described
in [\ref Iglesias2011, \ref Allauzen2014]. We call this the HiPDT decoder. A brief overview of it and an example on how to use it is given next.

In this framework, the RTN at the top-most cell of the CYK grid is
 converted into a PDA (via the Replace operation in the \ref OpenFst Extensions)
and efficiently
 composed with a language model to produce another PDA. To obtain the
 final output FSA, the PDA is expanded to an FSA either entirely (if
 memory is sufficient and the language model is small enough) or via pruned expansion (for larger language models). This is useful in
 exploring large and complex translation grammars where HiFST requires
 a lot of local pruning. However, it requires the language model to be
 'small' (for example, entropy-pruned as in
 [\ref Iglesias2011, \ref Allauzen2014]). Therefore, we then typically rescore the pruned
 output FSA with a stronger language model.

This whole setup can be accomplished in one single command as follows:

    > hifst.O2 --config=configs/CF.hiero.pdt &> log/log.hiero.pdt

Please see the config file for the parameters needed, along with explanatory comments.

In this particular example, the output 1-best for the first two
sentences is identical to the baseline Hiero case (with translation
via RTN replacement followed by composition). However, the output lattices differ as they contain
different hypotheses (due to the different pruning strategy).

\subsection pda_rtns Recursive Transition Networks

As already discussed with respect to \ref lpruning,
HiFST generates an initial representation of the space of translation in the form of an RTN,
which is then transformed either to WFSAs or to PDAs using the 
\ref OpenFst [Replace](http://openfst.org/twiki/bin/view/FST/ReplaceDoc) operation
prior to application of the language model.

HiFST can save the RTNs to disk, and the language model application and shortest path operations can be carried out using the \ref OpenFst command line tools.

For example,  consider generation of the baseline lattices with the Shallow-1 translation grammar and the 4-gram language model.  The command can be re-run, but with added instructions to save the RTNs to disk:

    > hifst.O2 --config=configs/CF.baseline --hifst.writertn=output/exp.baseline/rtn/?/%%rtn_label%%.fst --grammar.storentorder=output/exp.baseline/rtn/ntmap  --hifst.rtnopt=yes &> log/log.baseline.rtn

The RTNs are written to the directory `output/exp.baseline/rtn/*` as 

    > ls output/exp.baseline/rtn/1/
    1001000007.fst  1003001002.fst  1003003000.fst  1003004001.fst  1003006000.fst  1004002000.fst  1004005000.fst
    1003001000.fst  1003002000.fst  1003003001.fst  1003005000.fst  1003007000.fst  1004003000.fst  1004006000.fst
    1003001001.fst  1003002001.fst  1003004000.fst  1003005001.fst  1004001000.fst  1004004000.fst

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

In this example, the automata 1003001002.fst contains all derivations headed by X, the third non-terminal, and spanning source positions 1 to 3 (=1+2). 

The root automata is 1001000007.fst, since A=001 (the S non-terminal),
B=0 (the first source position), and C=7 (the sentence has 8 words).
This automata is a representation of all possible translations of the
source sentence under this grammar, as can be seen by printing its paths (here the first 2):

    > cat output/exp.baseline/rtn/1/1001000007.fst | printstrings.O2 --semiring=lexstdarc -u --nbest=2 2>/dev/null
    1 1004001000 11 384 1004003000 1004004000 1004005000 1004006000 2 
    1 1004001000 11 384 1003003001 1004005000 1004006000 2 
    

As can be seen, the symbols are a mix of target language symbols (1,2,11,384,...) and pointers to other automata (1004001000, 1004003000, ...).
Conversion of the RTN is done by recursive substitution of these symbols by the FSTs to which they point, starting from the root automata.

\subsection pda_replace Replacement: Translation by Converting RTNs to WFSAs

     > fstreplace | head -n 3
     Recursively replaces FST arcs with other FST(s).
    
     Usage: fstreplace root.fst rootlabel [rule1.fst label1 ...] [out.fst]

Note that the root FST and root label are always of the form 1001000C, where C = I - 1 , where I is the source sentence length.

HiFST uses the same names for 
rules and labels,  so we get get the filenames and labels in the right form by, e.g.

     > ls output/exp.baseline/rtn/1/1*.fst | sed 's,\(.*\)/\(.*\).fst,\1/\2.fst \2,' | head -n 5
     output/exp.baseline/rtn/1/1001000007.fst 1001000007
     output/exp.baseline/rtn/1/1003001000.fst 1003001000
     output/exp.baseline/rtn/1/1003001001.fst 1003001001
     output/exp.baseline/rtn/1/1003001002.fst 1003001002
     output/exp.baseline/rtn/1/1003002000.fst 1003002000

The following will expand the RTN into an FSA:

     > fstreplace `ls output/exp.baseline/rtn/1/1*.fst | sed 's,\(.*\)/\(.*\).fst,\1/\2.fst \2,'` > output/exp.baseline/rtn/1/T.fst

The WFSA T is the replacement of the RTN that was generated in translation.

\subsubsection rtn_lm_app Composition and Shortest Path

The applylm tool can be used to apply the baseline 4-gram language model to T via composition.  This generates a new WFSA containing both translation and language model scores:

- Input
   - M/lm.4g.mmap : n-gram LM
   - output/exp.baseline/rtn/1/T.fst : WFSA containing translation scores
- Output
   - output/exp.baseline/rtn/1/TG.fst.gz : WFSA containing translation grammar and LM scores

The output is written in the form of a transducer, with the RTN labels as the input symbols and the target language words on the output symbols:


     > applylm.O2 --lm.load=M/lm.4g.mmap --semiring=lexstdarc --lattice.load=output/exp.baseline/rtn/1/T.fst --lattice.store=output/exp.baseline/rtn/1/TG.fst.gz

     > zcat output/exp.baseline/rtn/1/TG.fst.gz | fstshortestpath | fstrmepsilon | fsttopsort | fstprint
     0    1 	1    		1	-2.609375,-2.609375
     1    2 	9121 		9121	9.33318996,-1.26074219
     2    3 	1004002000	0
     3    4 	384		384 	7.13530731,-2.609375
     4    5 	1004003000	0	1.28222656,1.28222656
     5    6 	6		6	-0.390115976,-3.328125
     6    7 	2756		2756	9.45967484,0.288085938
     7    8 	7		7	1.79730964,0
     8    9 	1004004000	0
     9    10	3		3	-0.395056069,-1.23925781
     10   11	4144		4144	9.78138161,0
     11   12	6		6	0.201819927,0
     12   13	1003005001	0	3.29199219,3.29199219
     13   14	1458528		1458528	10.2062063,-1.0703125
     14   15	1004005000	0
     15   16	1341		1341	6.04568958,1.55957031
     16   17	2		2	2.33047056,-2.34277344
     17

To see the translation alone, we project to the output symbols:
  
    > zcat output/exp.baseline/rtn/1/TG.fst.gz | fstproject --project_output | printstrings.O2 --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap 2>/dev/null
    <s> republican strategy of resistance to the renewal of obamas election </s> 			57.4707,-8.03809

which should agree with the previously generated contents of output/exp.baseline/LATS/1.fst.gz produced by the baseline system: 

    > zcat output/exp.baseline/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap 2>/dev/null
    <s> republican strategy of resistance to the renewal of obamas election </s> 	     57.4707,-8.03809

\subsection pda_expand Expansion: Translation by Composition of PDAs and WFSAs followed by Pruned Expansion


When using PDTs, the decoding process differs from the above in that the RTN is not expanded to an FSA prior to composition with the LM. Instead, HiPDT replaces the RTN by a PDA, which is efficiently composed with the LM to produce another PDA. Finally, this resulting PDA is converted to the final translation FSA via pruned expansion.

As explained in the example of \ref pda, this process is done by the decoder in one go. For explanatory reasons, here we reproduce it externally for one sentence via the command line.

(Note: as of March 2014 we have not managed to make the OpenFST PDT command line operations work well with our lexicographic library, so the standard tropical semirring must be used in this example. This makes it slightly more complex than it should be, but we believe it is useful to understand HiPDT anyway)

First, we dump the RTN for the full hiero grammar as follows:

    > hifst.O2 --config=configs/CF.hiero --hifst.writertn=output/exp.hiero/rtn/?/%%rtn_label%%.fst --grammar.storentorder=output/exp.hiero/rtn/ntmap --hifst.rtnopt=yes &> log/log.hiero.rtn

Then, we ensure that the RTN files are in the tropical semiring:

    > mkdir -p output/exp.hiero/rtn-tp/1 output/exp.hiero/rtn-tp/2
    > pushd output/exp.hiero/rtn/ ; for f in ?/100*.fst; do cat $f | lexmap.O2 --action=lex2std > ../rtn-tp/$f; done; popd

The PDT is then created as follows:

    > for f in 1 2; do pdtreplace --pdt_parentheses=output/exp.hiero/rtn-tp/$f/parens.txt `ls output/exp.hiero/rtn-tp/$f/1*.fst | sed 's,\(.*\)/\(.*\).fst,\1/\2.fst \2,'` > output/exp.hiero/rtn-tp/$f/T.pdt; done
    
where the `pdt_parentheses' option indicates that the open/close parentheses symbols are to be stored into a file. This is used later in order to expand the PDA to an FSA.

Then the PDA is composed with the weak language model. This is done via the standard composition algorithm, but making sure that open/close parentheses symbols are treated as epsilons by the composition algorithm. To accomplish this, their respective output symbols need to be relabel to 0 before applying the LM:

    > for f in 1 2; do cat output/exp.hiero/rtn-tp/1/parens.txt | tr '\t' '\n' | sed 's/$/\t0/' > output/exp.hiero/rtn-tp/$f/parens-to-epsilon.txt ; 
    > cat output/exp.hiero/rtn-tp/$f/T.pdt | fstrelabel -relabel_opairs=output/exp.hiero/rtn-tp/$f/parens-to-epsilon.txt > output/exp.hiero/rtn-tp/$f/Tb.pdt 
    > applylm.O2 --lm.load=M/lm.4g.eprnd.mmap --lattice.load=output/exp.hiero/rtn-tp/$f/Tb.pdt --lattice.store=output/exp.hiero/rtn-tp/$f/TG.pdt ; 
    > done

Then the resulting PDT is expanded into an FSA while applying a pruning weight of 9:

    > for f in 1 2; do fstproject output/exp.hiero/rtn-tp/$f/TG.pdt | pdtexpand --pdt_parentheses=output/exp.hiero/rtn-tp/$f/parens.txt --weight=9 > output/exp.hiero/rtn-tp/$f/TG.fst ; done

Finally, the weak LM is removed and the full LM is applied:
  
    > for f in 1 2; do applylm.O2 --lm.load=M/lm.4g.eprnd.mmap --lm.featureweights=-1 --lattice.load=output/exp.hiero/rtn-tp/$f/TG.fst --lattice.store=output/exp.hiero/rtn-tp/$f/TG-nolm.fst ; applylm.O2 --lm.load=M/lm.4g.mmap --lattice.load=output/exp.hiero/rtn-tp/$f/TG-nolm.fst --lattice.store=output/exp.hiero/rtn-tp/$f/TG-final.fst ; done

The final FSA that results from this process (`output/exp.hiero/rtn-tp/1/TG-final.fst`) should be equivalent to the one obtained by HiPDT (`output/exp.hiero.pdt/LATS/1.fst.gz`) except for numerical differences. Their 1-best hypothesis can be obtained as follows:

    > zcat output/exp.hiero.pdt/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc -w -m wmaps/wmt13.en.wmap 2>/dev/null
    <s> the republican strategy of resistance to the renewal of obama 's election </s> 	55.2515,-11.6445

    > cat output/exp.hiero/rtn-tp/1/TG-final.fst | printstrings.O2 -w -m wmaps/wmt13.en.wmap 2>/dev/null
	<s> the republican strategy of resistance to the renewal of obama 's election </s> 	55.2515

