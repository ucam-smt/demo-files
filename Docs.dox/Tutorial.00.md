\section Intro Introduction

This tutorial presents various tools and techniques developed in
the [Statistical Machine Translation](http://divf.eng.cam.ac.uk/smt) group at
the [Cambridge University Engineering Department](http://eng.cam.ac.uk).

The tutorial is intended to serve as a guide for the use of the tools, but our research publications contain the
best descriptions of the algorithms and modelling techniques described here.
The most relevant publications for this tutorial are listed below (\ref Refs).  In
particular, this tutorial is based on the Russian-English SMT system
developed for the WMT 2013 evaluation - we suggest reading the system description [\ref Pino2013] before starting on the tutorial.

Our complete publications can be found at <http://divf.eng.cam.ac.uk/smt/Main/SmtPapers>.

HiFST grew out of the Ph.D. thesis work of Gonzalo Iglesias.  

Contributors to this release are:  
- Graeme Blackwood
- Bill Byrne
- Adria de Gispert
- Federico Flego
- Gonzalo Iglesias
- Juan Pino
- Rory Waite
- Tong Xiao

with thanks to Cyril Allauzen and Michael Riley.

\subsection intro_features Features Included in this Release

- HiFST -- Hierarchical phrase-based statistical machine translation system based on \ref OpenFst
- Direct production of translation lattices as Weighted Finite State Automata
- Efficient WFSA rescoring procedures
- \ref OpenFst wrappers for direct inclusion of \ref KenLM and ARPA language models as WFSAs
- Lattice Minimum Bayes Risk decoding
- Lattice Minimum Error Rate training
- Tutorial for Hiero translation using Recursive Transition Networks and Pushdown Transducers
- Client/Server mode
- Shallow-N translation grammars
- Source-sentence `chopping' procedures
- WFSA true-casing
- ...


\section Refs Reading Material

\subsection Refs_decoding HiFST, HiPDT and Hierarchical Phrase-Based Decoding

\anchor deGispert2010 [deGispert2010]
*Hierarchical phrase-based translation with weighted finite state transducers and Shallow-N grammars*. <br>
A. de Gispert, G. Iglesias, G. Blackwood, E. R. Banga, and W. Byrne. Computational Linguistics, 36(3). 2010. <br>
<http://aclweb.org/anthology/J/J10/J10-3008.pdf>

\anchor Allauzen2014 [Allauzen2014]
*Pushdown automata in statistical machine translation*. <br>
C. Allauzen, W. Byrne, A. de Gispert, G. Iglesias, and M. Riley. Computational Linguistics. 2014. To appear.<br>
<http://mi.eng.cam.ac.uk/~wjb31/ppubs/cl2013.final.pdf>

\anchor Iglesias2009 [Iglesias2009]
*Hierarchical phrase-based translation with weighted finite state transducers.*<br> 
G. Iglesias, A. de Gispert, E. R. Banga, and W. Byrne. Proceedings of HLT. 2009.<br>
<http://aclweb.org/anthology//N/N09/N09-1049.pdf> <br>
<http://mi.eng.cam.ac.uk/~wjb31/ppubs/naaclhlt2009presentation.pdf>

\anchor Iglesias2011 [Iglesias2011]
*Hierarchical Phrase-based Translation Representations*. <br>
G. Iglesias, C. Allauzen, W. Byrne, A. de Gispert, M. Riley. Proceedings of EMNLP. 2011. <br>
<http://aclweb.org/anthology/D/D11/D11-1127.pdf>

\anchor Iglesias2009 [Iglesias2009]
*Rule filtering by pattern for efficient hierarchical translation*.<br>
G. Iglesias, A. de Gispert, E. R. Banga, and W. Byrne. Proceedings of EACL. 2009. <br>
<http://aclweb.org/anthology/E/E09/E09-1044.pdf> <br>

\anchor Chiang2007 [Chiang2007]
*Hierarchical phrase-based translation*.<br>
Computational Linguistics. 2007 <br>
<http://aclweb.org/anthology/J07-2003.pdf>

\subsection Refs_systems CUED SMT System Descriptions

\anchor Pino2013 [Pino2013]
*The University of Cambridge Russian-English System at WMT13*. <br> J. Pino, A. Waite, T. Xiao, A. de Gispert, F. Flego, and W. Byrne. 
Proceedings of the Eighth Workshop on Statistical Machine Translation. 2013. <br>
<http://aclweb.org/anthology//W/W13/W13-2225.pdf> 

\subsection Refs_fsts OpenFST and Related Modelling Techniques

\anchor OpenFst [OpenFst]
The OpenFST Toolkit <http://www.openfst.org/>

\anchor Roark2011 [Roark2011]
*Lexicographic semirings for exact automata encoding of sequence models.* <br> B. Roark, R. Sproat, and I. Shafran. Proceedings of ACL-HLT. 2011. <br>
<http://aclweb.org/anthology/P/P11/P11-2001.pdf>

\subsection Refs_lmbr Lattice Minimum Bayes Risk Decoding using WFSAs

\anchor BlackwoodPhD [BlackwoodPhD]
*Lattice rescoring methods for statistical machine translation*.<br> G. Blackwood.  Ph.D. Thesis. Cambridge University Engineering Department and Clare College. 2010. <br> 
<http://mi.eng.cam.ac.uk/~gwb24/publications/phd.thesis.pdf>

\anchor Blackwood2010 [Blackwood2010]
*Efficient path counting transducers for minimum Bayes-risk decoding of statistical machine translation lattices*.<br>
G. Blackwood, A. de Gispert, W. Byrne.  Proceedings of ACL Short Papers. 2010. <br>
<http://aclweb.org/anthology//P/P10/P10-2006.pdf>

\anchor Allauzen2010 [Allauzen2010]
*Expected Sequence Similarity Maximization*. <br> C. Allauzen, S. Kumar, W. Macherey, M. Mohri, M Riley.
  Proceedings of HLT-NAACL, 2010.  <br>
<http://aclweb.org/anthology//N/N10/N10-1139.pdf>

\subsection lmert_refs Lattice Mert

\anchor Macherey2008 [Macherey2008]
*Lattice-based Minimum Error Rate Training for Statistical Machine Translation*. <br>
W. Macherey, F. Och, I. Thayer, J. Uszkoreit.  Proceedings of EMNLP, 2008. <br>
<http://aclweb.org/anthology/D/D08/D08-1076.pdf>

\anchor Waite2012 [Waite2012]
*Lattice-based minimum error rate training using weighted finite-state transducers with tropical polynomial weights.* 
<br> A. Waite, G. Blackwood, and W. Byrne. Proceedings of FSMNLP, 2012.<br>
<http://aclweb.org/anthology-new/W/W12/W12-6219.pdf>

\subsection othertools Language Modelling Toolkits
\anchor SRILM [SRILM]
SRI Language Model Toolkit<br>
<http://www.speech.sri.com/projects/srilm/>

\anchor KenLM [KenLM]
The KenLM Toolkit<br>
<http://kheafield.com/code/kenlm/>



\section general Overview

\subsection build Installation

The code can be cloned from the following GitHub address:

    > git clone https://github.com/ucam-smt/ucam-smt.git

Once downloaded, go into the cloned directory and run this command:

    > ./build-tests.sh

This should download and install necessary dependencies,
compile the code and run tests. The `README.md` in the cloned directory also
contains useful information for the installation.

Files for this tutorial can be downloaded from the following GitHub address:

    > git clone https://github.com/ucam-smt/demo-files.git
    > gunzip wmaps/*.gz  ## Uncompress big wordmap files.

There are additional Supplementary Files which can be downloaded 
from <http://mi.eng.cam.ac.uk/~wjb31/data/hifst.release.May14/> .   

\subsection paths Paths and Environment Variables

The following instructions are for the Bash shell.

In the following, `HiFSTROOT` designates the cloned directory,
i.e. the following should be a complete path to the cloned directory

    > export HiFSTROOT=complete_path_to_hifst_cloned_directory

After HiFST is successfully built and tested,  the file $HiFSTROOT/Makefile.inc
will contain environment variable settings needed to run the HiFST
binaries and the OpenFST tools using the HiFST libraries.  To set these,
simply run

    > source $HiFSTROOT/Makefile.inc
    > export PATH=$HiFSTROOT/bin:$OPENFST_BIN:$PATH
    > export LD_LIBRARY_PATH=$HiFSTROOT/bin:$OPENFST_LIB

You should make sure that $HiFSTBINDIR is added first on the path and
the library path and that it preceeds the OpenFst directories.
If the LD\_LIBRARY\_PATH variable is not set correctly, you will see the message

    ERROR: GenericRegister::GetEntry : tropical_LT_tropical-arc.so: cannot open shared object file: No such file or directory
    ERROR: ReadFst : unknown arc type "tropical_LT_tropical" : standard input


\subsection Setup_files Directory Structure

The following directories contain the data files, configuration files, and model files needed for this tutorial.

     ./
     |-configs/ # Configuration files
     |-EN/      # English reference text
     |-G/       # Translation grammars
     |-M/       # Language models 
     |-RU/      # Russian input text
     |-scripts/ # Scripts for these demonstration exercises
     |-wmaps/   # Word maps, to map English and Russian text to integers

The following directories will be created after running this tutorial.

     ./
     |-log/     # Translation process log files
     |-output/  # Translation output, as 1-best hypotheses and lattices


\subsection Setup_configs Configuration Files and Command Line Options

As you work through the tutorial, please read the comments in the config files which explain some of the processing options.
The following configuration files are provided for the tutorial.  

     # baseline configuration: 4-gram LM and Shallow-1 translation grammar
     configs/CF.baseline : HiFST with 4-gram language model and a Shallow-1 grammar
     configs/CF.baseline.lmbr : lattice Minimum Bayes' Risk (LMBR) rescoring on top of baseline system
     configs/CF.baseline.outputnoprune : lattice output without pruning
     configs/CF.baseline.outputnoprune.lmrescore : lattice rescoring with language models
     # full Hiero grammar with 4-gram LM
     configs/CF.hiero : full Hiero grammar without pruning in search
     configs/CF.hiero.chopping : methods for dealing with long source sentences
     configs/CF.hiero.localprune  : full Hiero grammar with pruning in search 
     configs/CF.hiero.pdt : full Hiero grammar, decoding with push-down automata (HiPDT)
     # full, iterative lattice MERT script 
     configs/CF.lmert.alilats : Lattice MERT example, alignment lattices
     configs/CF.lmert.hyps : Lattice MERT example, initial hypotheses
     configs/CF.lmert.vecfea : Lattice MERT example, vector feature lattices
     # example feature generation for MERT and LMERT
     configs/CF.mert.alilats.nbest : MERT features, derivation-to-translation transducers, restricted to N-Best lists 
     configs/CF.mert.hyps : MERT features, initial hypotheses
     configs/CF.mert.vecfea.nbest  : MERT features, N-Best feature lists for MERT
     # misc
     configs/CF.recaser : recasing examples
     configs/CF.baseline.client : HiFST client-server example, client
     configs/CF.baseline.server : HiFST client-server example, server


HiFST uses the Boost libraries which provide support for 
[configuration files](http://www.boost.org/doc/libs/1_55_0/doc/html/program_options/overview.html).

Parameters can be supplied either on the command line or in the config files.  For example, the
following options could be provided on the command line:

     --hifst.prune=9 --hifst.replacefstbyarc.nonterminals=X,V 

Alternatively, they could be specified in a configuration file either as

     hifst.prune=9
     hifst.replacefstbyarc.nonterminals=X,V 

or as

     [hifst]
     prune=9
     replacefstbyarc.nonterminals=X,V 

\subsection wmaps Word Maps and Integer Mapped Files

HiFST uses [symbol tables](http://www.openfst.org/twiki/bin/view/FST/FstAdvancedUsage#Symbol_Tables)
as provided by \ref OpenFst to map between source and target
language text and the integer representation used internally by
the decoder.  See the \ref OpenFst [Quick Tour](http://www.openfst.org/twiki/bin/view/FST/FstQuickTour) for a
discussion of the use of symbol tables.  

Integer mappings for English and Russian are in the directory wmaps/ :

     wmaps/wmt13.en.wmap 
     wmaps/wmt13.en.all.wmap (a much larger version of wmaps/wmt13.en.wmap)
     wmaps/wmt13.ru.wmap
     wmaps/wmt13.ru.all.wmap (a much larger version of wmaps/wmt13.ru.wmap)

Note that HiFST reserves the integers 1 and 2 for the sentence-start and sentence-end symbols.  0 is the OpenFST epsilon symbol.  

The format of the wordmap files is straightforward, e.g.

     > head wmaps/wmt13.en.wmap 
     <epsilon>		      0
     <s>		      1
     </s>		      2
     the		      3
     ,			      4
     .			      5
     of			      6
     to			      7
     and		      8
     in			      9


Source text files are provided in integer format :

     RU/RU.set1.idx : integer mapped Russian text

     > head -2 RU/RU.set1.idx 
     1 20870 2447 5443 50916 78159 3621 2
     1 1716 20196 95123 154 1049 6778 996 9 239837 7 1799 4 2


The [FAR](http://openfst.org/twiki/bin/view/FST/FstExtensions) tools can be used to generate Russian text from the integer mapped files (see the discussion on \ref basic_latshyps).

     > farcompilestrings --entry_type=line RU/RU.set1.idx | farprintstrings --symbols=wmaps/wmt13.ru.wmap | head -2
     <s> республиканская стратегия сопротивления повторному избранию обамы </s>
     <s> лидеры республиканцев оправдывали свою политику необходимостью борьбы с фальсификациями на выборах . </s>




\subsection lms Language Models

English 3-gram and 4-gram language models are provided in both
[KenLM](http://kheafield.com/code/kenlm/) and
[ARPA](http://www.speech.sri.com/projects/srilm/manpages/ngram-format.5.html)
formats .  See [\ref Pino2013] for a description of how these LMs are built.

The following language models have restricted vocabulary corresponding
to the target side of the rules that apply to the first few sentences
of the tuning set RU.set1.idx . This is done so that the LMs are small
and quickly and easily loaded into memory.  
*Do not use these models except for the first few sentences in this tutorial.*

     M/lm.3g.arpa.gz : Kneser-Ney 3-gram language model in ARPA format 
     M/lm.3g.mmap : Kneser-Ney 3-gram language model in KenLM format
     M/lm.4g.arpa.gz : Kneser-Ney 4-gram language model in ARPA format 
     M/lm.4g.mmap : Kneser-Ney 4-gram language model in KenLM format
     M/lm.4g.eprnd.mmap : entropy pruned KN 4-gram LM in KenLM format
     M/lm.tc.gz : true-casing language model

The following large LMs are available from a separate download site (see \ref build).  
It covers the target-side vocabulary for the large translation grammars, and is suitable
 for running on the complete tune and test set included in this tutorial.
In particular, this second LM must be downloaded and uncompressed into the M/ directory prior to running
the MERT and LMERT scripts and examples (see \ref mert and \ref lmert).  

     M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap : KN 4gram LM in KenLM format
     M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.withoptions.mmap : quantized KN 4gram LM in KenLM format

Language models are in integer mapped format, e.g. for the ARPA files:

     > zcat M/lm.3g.arpa.gz | grep . | head -15
     \data\
     ngram 1=1348
     ngram 2=130054
     ngram 3=785733
     \1-grams:
     -1.0615243	<unk>
     -inf		<s>	-1.0853117
     -1.5690455	</s>
     -2.2388144	12	-1.0949439
     -2.682596	11	-0.872226
     -4.0860014	1547	-0.66412055
     -2.4807615	14	-0.8686333
     -2.9167347	25	-0.7014704
     -2.599824	22	-0.6987488
     -2.6652465	26	-0.7175091

We also provide an *entropy pruned* [\ref SRILM] version of the 4-gram language model
as used for decoding with Push-Down Automata [\ref Allauzen2014] ; this is described below in \ref pda .

     M/lm.4g.eprnd.arpa.gz : Entropy-pruned Kneser-Ney 4-gram language model in ARPA format 
     M/lm.4g.eprnd.mmap : Entropy-pruned Kneser-Ney 4-gram language model in KenLM format

\subsection tgrammars Translation Grammars 
HiFST uses Synchronous Context-Free Grammars (SCFGs) for translation.
A full Hiero and a Shallow-1 translation grammar are provided in the `G/` directory:

     G/rules.hiero.gz : full hiero grammar with scalar translation scores
     G/rules.shallow.gz : Shallow-1 hiero grammar with scalar translation scores

We also provide versions of these grammars with raw, unweighted  feature scores:

     G/rules.hiero.vecfea.gz : full hiero grammar with feature vectors
     G/rules.shallow.vecfea.gz : Shallow-1 hiero grammar with feature vectors

For the tutorial on optimization (\ref mert), larger grammars corresponding
to the entire `RU/RU.tune.idx` tune set are provided:

     G/rules.shallow.all.gz : larger Shallow-1 hiero grammar with scalar translation scores
     G/rules.shallow.vecfea.allgz : larger Shallow-1 hiero grammar with feature vectors

There is also a grammar provided for the true-casing example (\ref true_casing) 
  
      G/tc.unimap

\subsubsection rules Grammar File Formats

In the grammar file, each line represents a rule. The rule format is:
  
     LHS RHS_SOURCE RHS_TARGET FEA_1 [FEA_2 FEA_3 FEA_4 ...]

where 

     LHS = the left hand side of the rule
     RHS_SOURCE = the source-language part of the right hand side of the rule
     RHS_TARGET = the target-language part of the right hand side of the rule
     FEA_i = the i-th component of the feature vector associated with the rule

The left hand side of a rule is a non-terminal symbol (in uppercase). 
The right hand side is a pair of terminal and non-terminal
symbol sequences in the source and target languages.  

\paragraph tgrammars_formats_fea Feature Vectors

Scores are assigned to rules as the dot product of a rule-specific feature vector 
and a weight vector (see the discussion in \ref mert).  This
computation can be done offline, in which case the feature for every rule in the grammar is a
1-dimensional scalar. Alternatively, the decoder can be provided with a weight vector which is applied 
to the feature vectors while loading the grammar.

For example, the grammar `G/rules.shallow.gz` provided in this tutorial the following set of weights was found via LMERT tuning (see \ref mert ):
 
    0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136

These can be applied to the Shallow-1 grammar, as follows:
    
    > WV=0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136
    > zcat G/rules.shallow.vecfea.gz | scripts/weightgrammar -w=$WV | head -3
    V 3 4 -2.046860955276
    V 3 4_3 -1.884009085882
    V 3 8 1.857985226112

and this should agree with the scalar-valued version of the grammar:

    > zcat G/rules.shallow.gz | head -3
    V 3 4 -2.046860955276
    V 3 4_3 -1.884009085882
    V 3 8 1.857985226112

\paragraph tgrammars_formats_nt Non-Terminals

In translation, a non-terminal `X` on the right hand side can be
rewritten by any rule whose left hand side is `X`. HiFST places
no restrictions on the definition of terminal and non-terminal
sequences in an SCFG rule; similarly, there are no constraints on how
many non-terminal symbols can be used in a rule (i.e. there are no constraints on order of the
SCFG).  However using a full Hiero grammar can lead to slow
translation, and this tutorial discusses several strategies for
pruning in translation and for translation grammar pruning.

Here is a small sample translation grammar

     M 434_M 1462_8_M -1.81842                
     M 7_M 9_3_M -0.735445                    
     M V V -0                                 
     S S_X S_X 0.05768                        
     S X X -0                                 
     V 10806 1411 1.16623                     
     V 164_M_60 78_M_8 -0.226464              
     V 164_M2_60_M1 78_M1_8_M2 -0.226464      
     V 21_591 39_258_8 -0.510102              
     V 24 3_54 -2.50252                       
     V 274_M_4 709_9_3_M -0.589246            
     V 5 6 -1.81729                           
     V 7_1689 9_741_8 0.438945                
     V 8 23 -1.46604                          
     X 1 1 -2.5598                            
     X 2 2 -2.5598                            
     X V V -0                                 
     D 1775 <dr> 10.4327                      
     S S_D_X S_D_X 0.11536                    


This grammar has four non-terminal symbols: `S`, `M`, `V` and `D`, and a 1-dimensional weight.  The terminal symbols are integers, corresponding to words in the source and target language word maps (\ref wmaps).  The symbol  `<dr>`
is a special symbol used by HiFST to represent an empty word, to indicate deletion.


As an example, for rule 

     V 164_M_60 78_M_8 -0.226464

we have

     LHS        = V
     RHS_SOURCE = 164_M_60
     RHS_TARGET = 78_M_8
     WEIGHT_1   = -0.226464

With this rule the decoder can rewrite the non-terminal `V` by replacing it by `164_M_60`
in the source language and by `78_M_8`
in the target language;  the rule is applied with
a score of -0.226464. Similarly, rule `V 5 6 -1.81729`
replaces `V` by the word "5" in the source-language and with the word
"6" in the target-language, with a score of -1.81729.

Indices on non-terminals indicate alignment within rules with more than one non-terminal. For example, for rule
  
    V 164_M2_6_M1 78_M1_8_M2 -0.226464

the `M` non-terminals on both language sides are indexed by 1 or 2; that is, `M1` in the source
language is linked with `M1` in the target language, and `M2` in the
source language is linked with `M2` in the target.
Strictly speaking, `M2` is not a non-terminal in the above example: it is the second
instance of the non-terminal `M` in the rule.
Obviously this is a reordering rule.

In general we use different types of rule to distinguish different
translation cases and obtain a finer-grained model. In this example, the `S`
rules are doing something rather similar to the glue rules used in
Hiero-style systems; the `M` rules can be regarded as monotonic
translation rules; the `V` rules can be regarded as reordering
translation rules and phrasal translation rules; and the `D` rule can be
regarded as an explicit operation of word deletion.

Note that there is a straight-forward correspondence between the
Hiero-style rule notation introduced by [\ref Chiang2007]
and the HiFST rule file format (for rules with
one-dimensional weights).  For example, the HiFST grammar file entries

    V 164_M2_6_M1 78_M1_8_M2 -0.226464
    S S_X S_X 0.05768

can be written as

    V -> < 164 M2 6 M1 ,  78 M1 8 M2 > / -0.226464
    S -> < S X , S X > / 0.05768


\subsubsection tgrammars_shallow  Shallow-N Translation Grammars

Shallow grammars [\ref deGispert2010] can be used to control the degree of nesting allowed within an hierarchical grammar.
For example, for a Shallow-1 Grammar, variables in a rule can be substituted only by phrases. That is,
hierarchical rules can be used only once to generate words; once a hierarchical rule is used, translation relies on glue rules to cover longer source spans.

Formally, we use W to denote the set of terminals, and S
and X to denote two non-terminals. A simple 
Hiero-style grammar can be defined to be:

     S -> X, X                                           
     S -> S X, S X                                       
     X -> a, b        where a, b \in ({X} union W)^+

We can transform this into a Shallow-1 grammar as
  
     S -> X, X                                           
     S -> S X, S X                                       
     Y -> a, b        where a, b \in {W}^+               
     X -> u, v        where u, v \in {{Y} union W}^+ 

Here `Y` is introduced to handle phrasal translations. The variables in rule `X -> u, v` can only be substituted with the `Y` rules.

In some cases it is desirable to allow more complex movement in 
translation, such as complex structure movements in Chinese-English
translation. For this we can use a generalisation of the simple
Shallow-1 grammar, called Shallow-N grammars.  These grammars allow hierarchical
rules to be applied up to N times.
For example, below is the form of a Shallow-2 grammar.

     S -> X, X                                           
     S -> S X, S X                                       
     Y^0 -> a^0, b^0  where a^0, b^0 \in {W}^+           
     Y^1 -> a^1, b^1  where a^1, b^1 \in {{Y^0} union W}^+ 
     X -> u, v        where u, v \in {{Y^1} union W}^+     
  

The Shallow-2 grammar introduces `Y^0` and `Y^1` to handle hierarchical
rule application at two levels within a derivation. For more detailed
description of Shallow-n grammars, please refer to the HiFST paper [\ref deGispert2010].








 


