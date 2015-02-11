HiFST Data and Control Files  {#tutorial_}
=============================

**Note:** Make sure that environment variables are set as described in \ref tutorial_install and \ref hifst_paths. 

\section tutorial_directories Tutorial Directory Structure

The following directories contain the data files, configuration files, and model files needed for this tutorial.

     ./
     |-configs/ # Configuration files
     |-train/   # Training data files
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


There are additional Supplementary Files which can be downloaded
from <http://mi.eng.cam.ac.uk/~wjb31/data/hifst.release.May14/> ; these should be put in the `M/` directory.

\section Setup_configs Configuration Files and Command Line Options

HiFST uses the Boost libraries which provide support for command line options and 
[configuration files](http://www.boost.org/doc/libs/1_55_0/doc/html/program_options/overview.html).
For example, the
following options could be provided on the command line:

     --hifst.prune=9 --hifst.replacefstbyarc.nonterminals=X,V

Alternatively, they could be specified in a configuration file either as

     hifst.prune=9
     hifst.replacefstbyarc.nonterminals=X,V

or as

     [hifst]
     prune=9
     replacefstbyarc.nonterminals=X,V

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


\section wmaps Word Maps

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

Note that HiFST reserves the integers 1 and 2 for the sentence-start and sentence-end symbols.  0 is the \ref OpenFst epsilon symbol.  

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

\section wmappedfiles Integer-Mapped Text Files

Source text files are provided in integer format :

     RU/RU.set1.idx : integer mapped Russian text

     > head -2 RU/RU.set1.idx
     1 20870 2447 5443 50916 78159 3621 2
     1 1716 20196 95123 154 1049 6778 996 9 239837 7 1799 4 2


The \ref OpenFst [FAR](http://openfst.org/twiki/bin/view/FST/FstExtensions) tools can be used to generate Russian text from the integer mapped files (see the discussion on \ref basic_latshyps).

     > farcompilestrings --entry_type=line RU/RU.set1.idx | farprintstrings --symbols=wmaps/wmt13.ru.wmap | head -2
     <s> республиканская стратегия сопротивления повторному избранию обамы </s>
     <s> лидеры республиканцев оправдывали свою политику необходимостью борьбы с фальсификациями на выборах . </s>




\section lms Language Models

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

\section tgrammars Translation Grammars
HiFST uses Synchronous Context-Free Grammars (SCFGs) for translation.
A full Hiero and a Shallow-1 translation grammar are provided in the `G/` directory:

     G/rules.hiero.gz : full hiero grammar with scalar grammar scores
     G/rules.shallow.gz : Shallow-1 hiero grammar with scalar grammar scores

We also provide versions of these grammars with raw, unweighted feature vectors:

     G/rules.hiero.vecfea.gz : full hiero grammar with feature vectors
     G/rules.shallow.vecfea.gz : Shallow-1 hiero grammar with feature vectors

For the tutorial on optimization (\ref mert), larger grammars corresponding
to the entire `RU/RU.tune.idx` tune set are provided:

     G/rules.shallow.all.gz : larger Shallow-1 hiero grammar with scalar grammar scores
     G/rules.shallow.vecfea.allgz : larger Shallow-1 hiero grammar with unweighted feature vectors

There is also a grammar provided for the true-casing example (\ref true_casing)

      G/tc.unimap

\subsection rules Grammar File Formats

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

\subsection tgrammars_formats_fea Feature Vectors

Scores are assigned to rules as the dot product of a rule-specific feature vector
and a weight vector ([\ref Chiang2007] and see the discussion in \ref mert).  This
computation can be done offline, in which case the feature for every rule in the grammar is a
1-dimensional scalar. Alternatively, the decoder can be provided with a weight vector which is applied
to the feature vectors while loading the grammar.

For example, the grammar `G/rules.shallow.gz` provided in this tutorial the following set of weights was found via LMERT tuning (see \ref mert ):

    0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136

These can be applied to the Shallow-1 grammar, as follows:

    > gzip -d -c G/rules.shallow.vecfea.gz | head -3
    V 3 4 0.223527 0.116794 -1 -1 0 0 0 0 -1 1.268789 0.687159
    V 3 4_3 3.333756 0.338107 -2 -1 0 0 0 0 -1 1.662178 3.363062
    V 3 8 3.74095 3.279819 -1 -1 0 0 0 0 -1 3.741382 2.271445

    > GW=0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136

    > zcat G/rules.shallow.vecfea.gz | scripts/weightgrammar -w=$GW | head -3
    V 3 4 -2.046860955276
    V 3 4_3 -1.884009085882
    V 3 8 1.857985226112

and this should agree with the scalar-valued version of the grammar:

    > zcat G/rules.shallow.gz | head -3
    V 3 4 -2.046860955276
    V 3 4_3 -1.884009085882
    V 3 8 1.857985226112

**Note** that the unweighted feature vector contains all features
  needed to compute the score of a translation, *except* for the
  contributions from the language model(s).


\subsection tgrammars_formats_nt Non-Terminals

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
rules are doing something very similar to the glue rules used in
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


\subsection tgrammars_shallow  Shallow-N Translation Grammars

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
