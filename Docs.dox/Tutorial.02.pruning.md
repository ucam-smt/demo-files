Pruning
=============
\section lpruning Local pruning / pruning in search

Local pruning controls processing speed and memory use during translation.  
Only enough details are reviewed here to describe how HiFST performs pruning in search;
for a detailed discussion of local pruning and pruning in search, see Section 2.2.2 of [\ref deGispert2010].  

Given a translation grammar and a source language sentence, HiFST first
constructs a Recursive Transition Network (RTN) representing
the translation hypotheses [\ref Iglesias2009, \ref Iglesias2011].
This is done as part of a modified CYK algorithm used to parse the
source sentence under the translation grammar.
The RTN is then *expanded* to an equivalent WFSA via the \ref OpenFst [Replace](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ReplaceDoc)
operation. This WFSA contains the translation hypotheses along with their scores under the translation grammar.  
We refer to this as the `top-level' WFSA, because it is associated with the top-most cell in the CYK grid.
This top-level WFSA can be pruned after composition with the language
model, as described in the discussion of \ref basic_toplevelpruning.
We refer to this as *exact search* or *exact translation*.
In exact translation, no translation hypotheses are discarded prior to applying the complete translation and language model scores.

Exact translation can be done under some combinations of translation grammars, language models, and language pairs.
In particular, the \ref tgrammars_shallow  were designed for exact search.
However attempting exact translation under many translation grammars would cause
either the [Replace](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ReplaceDoc)
operation or the subsequent language model composition to
become computationally intractable.
We therefore have developed a pruning strategy that prunes the RTN during its construction.

The RTN created by HiFST can be described as follows:
  - \f$X\f$ is the set of non-terminals in the translation grammar, with \f$S\f$ as the root
  - \f$\Sigma\f$ is the target language vocabulary, i.e. the terminals in the target language
  - \f$I\f$ is the length of the source sentence \f$s\f$, i.e. \f$s = s_0...s_{I - 1}\f$
  - A new set of non-terminals is defined as \f$N = \{ (x,i,j) : x \in X , 0 <= i <= j < I \}\f$
     - Note that \f$(S,0,I-1) \in N\f$
  - \f$(T_u)_{u \in N}\f$, is a family of WFSAs with input alphabet \f$\Sigma \cup N\f$
     - Each \f$T_u\f$ with \f$u = (x, i, j)\f$, is a WFSA that describes all applications of translation rules with left-hand side non-terminal \f$x\f$ that
span the substring \f$s_i ... s_j\f$
     - \f$T_u\f$ is associated with the CYK grid cell associated with source space \f$[i,j]\f$ and headed by non-terminal \f$x\f$
  - The top-level RTN is defined as \f$R_{(S,0,I-1)} = (N, \Sigma, (T_u)_{u \in N}, (S,0,I-1))\f$.
     - The root symbol of this RTN is \f$(S,0,I-1)\f$.
     - The WFSA \f$T_{(S,0,I-1)}\f$ represents all applications of translation rules that span the entire sentence and are rooted with non-terminal \f$S\f$.

Exact translation is achieved if every \f$T_u\f$ is complete (i.e. if no pruning is done) prior to the \ref OpenFst [Replace](http://openfst.org/twiki/bin/view/FST/ReplaceDoc)
operation
on the RTN \f$R_{(S,0,I-1)}\f$. This produces a WFSA that contains all translations
that can be produced under the translation grammar.  

The RTN pruning strategy relies on noting
that each of the WFSAs \f$T_{u'}\f$, \f$u' = (x', i', j')\f$, also defines an RTN \f$R_{u'}\f$, as follows:
  - Define a subset of non-terminals \f$N' = \{ (x,i,j) : x \in X , i' <= i <=j < j' \}\f$ , i.e. \f$N' \subset N\f$
  - \f$R_{u'} = (N', (T_u)_{u \in N'}, (x', i', j') )\f$
      - The root symbol of this RTN is \f$(x', i', j')\f$

The [Replace](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ReplaceDoc)
operation can be applied to the RTNs \f$R_{u'}\f$ to produce an WFSA
containing all translations of the source string \f$S_{i'} ... S_{j'}\f$ using
derivations rooted in the non-terminal \f$x'\f$.  This WFSA can be pruned and used in place of the original \f$T_{u'}\f$.

Because of the possibility of search errors we refer to this as 'local pruning' or inadmissible pruning.
There is the possibility that pruning any of the \f$T_u\f$ may possibly cause some good translations to be discarded.
For this reason it is important to tune the pruning strategy for the translation grammar and language model.
Once pruning has been set, the benefits are
  - faster creation of the top-level WFSA via the [Replace](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ReplaceDoc) operation
  - faster composition of the translation WFSA with the language model
  - less memory used in RTN construction and language model composition

Local pruning should be done under the combined
translation and the language model scores, rather than under the translation grammar scores alone
alone. However, the LM used in local pruning can be relatively weak. For
example, if the main language model used in translation is a 4-gram,
perhaps a 3-gram or even a bigram language model could be used in
local pruning.  Using a smaller language model will make pruning faster, as
will an efficient scheme to remove the scores of the language models used in pruning.  
The lexicographic semiring, see \ref basic_scores, makes this last operation easy.

\section local_prune Local Pruning Algorithm

HiFST monitors the size of the \f$T_u\f$ during translation. Any of these automata that exceed specified thresholds
are converted to WFSAs and pruned.  Subsequent expansion of the RTN  \f$R_{(S,0,I-1)}\f$ is then done with respect to the pruned
versions of \f$T_u\f$.


Local pruning is controlled via the following HiFST parameters:

    hifst.localprune.enable=yes # must be set to activate local pruning
    hifst.localprune.conditions=NT_1,span_1,size_1,threshold_1,...,NT_N,span_N,size_N,threshold_N
    hifst.localprune.lm.load=lm_1,...lm_K
    hifst.localprune.lm.featureweights=scale_1,...,scale_K
    hifst.localprune.lm.wps=wp_1,...,wp_K

In the above, an arbitrary number N of tuples (`NT_n`, `span_n`, `size_n`, `threshold_n`) can be provided;
similarly, an arbitrary number K of language model parameters (`lm_k`, `scale_k`, `wp_k`) can also be used in pruning.

Pruning is applied during construction of the RTN, as follows:

  - If any \f$T_u\f$ satisfies the following conditions for any parameter set (`NT_n`, `span_n`, `size_n`, `threshold_n`), n=1,...,N
        - NT_n = X
        - span_n <= j-i
        - size_n <= number of states of \f$T_u\f$, computed via \ref OpenFst `NumStates()`
  - then \f$T_u\f$ is pruned as follows:
      - OpenFst [Replace](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ReplaceDoc) converts \f$R_u\f$ to a WFSA
      - [RmEpsilon](http://www.openfst.org/twiki/bin/view/FST/RmEpsilonDoc),[Deteminize](http://www.openfst.org/twiki/bin/view/FST/DeterminizeDoc), and [Minimize](http://www.openfst.org/twiki/bin/view/FST/MinimizeDoc) generate a compacted WFSA
      - [Composition](http://www.openfst.org/twiki/bin/view/FST/ComposeDoc) with K language model(s) WFSAs
          - The parameters (`lm_k`, `scale_k`, `wp_k`) specify the language models, language model scale factors, and word penalties to be applied
      - OpenFst [Prune](http://www.openfst.org/twiki/bin/view/FST/PruneDoc) is applied with threshold `threshold_n`
      - Language model scores are removed by copying component weights in the lexicographic semiring, see \ref basic_scores
      - [RmEpsilon](http://www.openfst.org/twiki/bin/view/FST/RmEpsilonDoc),[Deteminize](http://www.openfst.org/twiki/bin/view/FST/DeterminizeDoc), and [Minimize](http://www.openfst.org/twiki/bin/view/FST/MinimizeDoc), yielding a pruned WFSA \f$T_u\f$ with only translation scores and target language symbols
  - The pruned version of \f$T_u\f$ is then used in place of the original version in the RTN

\section lpruning_effects Effect on Speed, Memory, Scores

Pruning in search is particularly important when running HiFST with
grammars that are more powerful than the shallow grammar used in
earlier examples.

For example, HiFST can be run with a full Hiero grammar,
while monitoring memory consumption via the UNIX top command:

     > (time hifst.O2 --config=configs/CF.hiero) &> log/log.hiero

The memory use is approximately 2GB and translation takes approximately 1m45s.
(The resource consumption may vary depending on your hardware, we provide these
numbers to illustrate the effect of local pruning.)

If translation is performed with the same grammar and language model, but with local pruning,

     > (time hifst.O2 --config=configs/CF.hiero.localprune) &> log/log.hiero.localprune

then the memory consumption is reduced to under 300MB and the
processing time to approximately 25s.  Inspecting the log file
indicates that local pruning was applied to 18 sublattices for the
second sentence:

     > tail -n 16 log/log.hiero.localprune | head -n 12
     Fri May  9 15:20:38 2014: run.INF:=====Translate sentence 1:1 20870 2447 5443 50916 78159 3621 2
     Fri May  9 15:20:38 2014: run.INF:Loading hierarchical grammar: G/rules.hiero.gz
     Fri May  9 15:20:38 2014: run.INF:loading LM=M/lm.4g.mmap
     Fri May  9 15:20:38 2014: run.INF:loading LM=M/lm.3g.mmap
     Fri May  9 15:20:38 2014: run.INF:Stats for Sentence 1: local pruning, number of times=0
     Fri May  9 15:20:38 2014: run.INF:End Sentence ******************************************************
     Fri May  9 15:20:38 2014: run.INF:Translation 1best is: 1 3 9121 384 6 2756 7 3 4144 6 159312 42 1341 2
     Fri May  9 15:20:38 2014: run.INF:=====Translate sentence 2:1 1716 20196 95123 154 1049 6778 996 9 239837 7 1799 4 2
     Fri May  9 15:20:47 2014: run.INF:Stats for Sentence 2: local pruning, number of times=18
     Fri May  9 15:20:55 2014: run.INF:End Sentence ******************************************************
     Fri May  9 15:20:56 2014: run.INF:Translation 1best is: 1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2
     Fri May  9 15:20:56 2014: main.INF:hifst.O2 ends!

In this case, local pruning has no effect on the translations produced:

     > head output/exp.hiero.localprune/hyps output/exp.hiero/hyps
     ==> output/exp.hiero.localprune/hyps <==
     1 3 9121 384 6 2756 7 3 4144 6 159312 42 1341 2
     1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2

     ==> output/exp.hiero/hyps <==
     1 3 9121 384 6 2756 7 3 4144 6 159312 42 1341 2
     1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2

The effect of pruning can be more dramatic on longer, more difficult
to translate sentences.  For example, the third sentence in this set
is difficult to translate under the full Hiero grammar without
pruning, although it can be translated using local pruning as

     > (time hifst.O2 --config=configs/CF.hiero.localprune --range=3:3) &> log/log.hiero.localprune2

Even with local pruning, the processing time for this one sentence is over 4 minutes.

By comparison, translation is much faster with much more aggressive local pruning, which we introduce
via command line options to override the settings in the configuration
file:

     > (time hifst.O2 --config=configs/CF.hiero.localprune --range=3:3 --hifst.lattice.store=output/exp.hiero.localprunemore/LATS/?.fst.gz --target.store=output/exp.hiero.localprunemore/hyps --hifst.localprune.conditions=X,3,10,1,V,3,10,1) &> log/log.hiero.localprune3

Translation finishes in less than 6 seconds, but this more aggressive local pruning
changes the translation hypothesis:

     > zcat output/exp.hiero.localprune/LATS/3.fst.gz | printstrings.O2 -w --semiring=lexstdarc -m wmaps/wmt13.en.wmap 2>/dev/null
     <s> however , in the heart of the take the last myth , arguing that the rare cases of fraud in elections in the united states , the deaths of a lightning strike . </s>  128.842,-0.150391

     > zcat output/exp.hiero.localprunemore/LATS/3.fst.gz | printstrings.O2 -w --semiring=lexstdarc -m wmaps/wmt13.en.wmap 2>/dev/null
     <s> however , in the heart of the take the last myth , arguing that a rare cases of fraud in elections in the united states , the deaths of a lightning strike . </s>  130.054,-0.943359



The best hypothesis generated with less local pruning in `exp.hiero.localprune/` has a combined
translation and language model score of 128.842 .  This hypothesis
does not survive more local pruning in `exp.hiero.localprunemore/` , where the best hypothesis has a higher
combined score of 130.054 .

\section chopping Source Sentence Chopping

Long source sentences make the translation process slow and expensive
in memory consumption; see [\ref Allauzen2014] for a discussion of how
source sentence length affects computational complexity and memory use
by HiFST and HiPDT.  There are various strategies for controlling
translation complexity; pruning has been discussed (\ref lpruning), and it is also
possible to set the maximum span and gap spans allowed in translation
so as to control computational complexity. However translation quality
can be affected if pruning is too heavy or if span constraints are set
too aggressively.

An alternative approach is to 'chop' long sentences into shorter
segements which can then be translated separately. If the sentence
chopping is done carefully, the impact on the translation quality can
be minimized.  The benefits to chopping are faster translation that
consumes less memory.  The potential drawbacks are twofold: chopping
can prevent the search procedure from finding good hypothesis under
the grammar, and care must be taken to correctly apply the target
language model at the sentence level.

\section chopping_gb Grammar-based Sentence Chopping

Chopping can be done by inserting the special 'chop' symbol
'0' in the source sentence, and then translating with a modified
grammar.  The chopping grammar is constructed so that translation
rules are not applied across the chopping points, thus limiting the
space of translation that are generated.  Conceptually, translation proceeds as:
   -# the translation grammar is applied separately to source sentence segments demarcated by chop symbols
   -# local pruning can be applied to the translations of these segments
   -# the resulting WFSAs containing translations of the segments are concatenated under the chopping grammar, possibly with local pruning
   -# the language model is applied
   -# top-level, admissible pruning is done under the translation and languaage model scores

In this way the FSTs produced by translating the segments are
concatenated prior to application of the target language model; in
this way the language model context is not broken by the source
sentence chopping.

As an example, a grammar modified for chopping contains the following rules (without
weights):

     R 1 1
     R R_D_X R_D_X
     R R_X R_X

     T 0 0
     T T_D_X T_D_X
     T T_X T_X

     S S_U S_U
     S Q Q
     Q R R
     U T T

The rules in the first block above are similar to those used in the
usual Hiero grammar, with the original '`S`' changed to '`R`'. These rules
are responsible for concatenating the partial translations of the source
sentence, starting from the sentence-start symbol
'1', up to but not including the first instance of the chopping symbol
'0'.

Each subsequent sequence of source words starting with symbol '0', is
handled in a similar way by the second block of rules above. Note that
the only rule that can be applied to the input symbol '0' is '`T 0 0`', making the
translation of each chopped segment independent.  This makes use of
the OpenFST convention of mapping 0 to epsilon: the 0's in the input
are parsed as regular symbols by HiFST, while 0's on the output side
are mapped to epsilons and ignored in composition with the language
model.

The third block of rules above will join together the results obtained
for each chopped segment. As with the glue rule '`S`' in the usual Hiero
grammar, it is necessary to allow this new set of rules to be applied
to any span. This is done by setting

      cykparser.ntexceptionsmaxspan=S,Q,R,T,U

The additional mapping provided by the last two rules controls
the pruning applied to the top CYK cell relative to each
chopped segment:

      hifst.localprune.conditions=Q,1,100,12,U,1,100,12,X,5,10000,9,V,3,20000,9

In the above example tighter parameters are chosen for '`Q`' and '`U`' to
force pruning.  In this way the final lattice obtained by
concatenation is prevented from growing too large.  However a wider
beam (12) with respect to the other cell types is used, to avoid
discarding too many potentially useful hypotheses.

It is possible to specify explicitly that FSTs generated for rules
with LHS '`X`' or '`V`' can be kept as pointers rather then expanded in
the FST (RTN) that is built for a higher CYK cell. This is achieved
setting

      hifst.replacefstbyarc=X,V
      hifst.replacefstbyarc.exceptions=S,R,T

The second line above prevents substitution for rules with LHS
'`S`', '`R`' and '`T`'.  It is better to have a fully expanded FST for these
rules for more effective optimisation (Determinization and Minimisation).

\section chopping_eg Converting Grammars and Input Text for Chopping

The usual Hiero grammar can be converted for chopping, as follows; note that no-cost, 0 valued, weights are added to rules :

First, create the chopping and glue rules:

     > (echo "T T_D_X T_D_X 0" ; echo "T T_X T_X 0" ; echo "T 0 0 0") > G/rules.hiero.chop
     > (echo "S S_U S_U 0" ; echo "U T T 0" ; echo "Q R R 0" ; echo "S Q Q 0") >> G/rules.hiero.chop
     > cat G/rules.hiero.chop
     T T_D_X T_D_X 0
     T T_X T_X 0
     T 0 0 0
     S S_U S_U 0
     U T T 0
     Q R R 0
     S Q Q 0

Next, append all rules, mapping glue rules with LHS S to LHS R:

     > zcat G/rules.hiero.gz | sed 's,S,R,g' >> G/rules.hiero.chop
     > gzip G/rules.hiero.chop

The source text (`RU/RU.set1.chop.idx`) will be chopped simply inserting
the chopping marker '0' after each comma (integer mapped to 3 in the
Russian wordmap); this
is a simplistic approach that is easily implemented for this
demonstration:

     > sed 's, 3 , 3 0 ,g' RU/RU.set1.idx > RU/RU.set1.chopping.idx

     > diff RU/RU.set1.idx RU/RU.set1.chopping.idx | head -n4
     3c3
     < 1 109 5 458 756435 1225 1358 60145 3 12725 3 11 3678 66369 7 1799 5 1317 2946 45 32023 3 75 3678 1102 24 10272 28960 4 2
     ---
     > 1 109 5 458 756435 1225 1358 60145 3 0 12725 3 0 11 3678 66369 7 1799 5 1317 2946 45 32023 3 0 75 3678 1102 24 10272 28960 4 2

The following command will translate lines 3,12,19 in the Russian
integer-mapped file RU/RU.set1.chop.idx :

     # Run HiFST, with chopping.  Input is the chopped source RU/RU.set1.chopping.idx.
     # hypotheses are written to output/exp.chopping/chop/hyps and lattices to output/exp.chopping/chop/LATS/
     > (time hifst.O2 --config=configs/CF.hiero.chopping) &> log/log.chopping.chop

Now we decode again keeping the same configuration (same grammar and language model), but with the
non-chopped version of the input:

     # Run HiFST, without chopping.  Input is the original, unchopped source RU/RU.set1.idx
     # hypotheses are written to output/exp.chopping/nochop/hyps and lattices to output/exp.chopping/nochop/LATS/
     > (time hifst.O2 --config=configs/CF.hiero.chopping --source.load=RU/RU.set1.idx --target.store=output/exp.chopping/nochop/hyps --hifst.lattice.store=output/exp.chopping/nochop/LATS/?.fst.gz) &> log/log.chopping.nochop

Comparing the time and memory consumption of the two experiments shows that source-sentence chopping is significantly faster and uses far less memory; in particular, local pruning is required less often under the chopping grammar:

                  	                     Number of local prunings
     Input      Tot time      Max memory    Sent 3    Sent 12   Sent 19
     --------   --------      ----------    ------    -------   -------
     Unchopped  22m 37s         5.4Gb	     92        106       168
     Chopped	 3m 57s         0.8Gb	     34         46        20

However, chopping restricts the space of translations.  Looking at the
scores of the best translation hypotheses, chopping the source
sentence prevents the decoder from finding the best scoring hypothesis
under the grammar; for the third sentence, the hypothesis produced
without chopping has a lower (i.e. better) combined cost (128.842)
than the hypothesis produced with chopping (130.309):


     # find the score of the best hypothesis for the 3rd sentence, without chopping
     > zcat output/exp.chopping/nochop/LATS/3.fst.gz | printstrings.O2 --semiring=lexstdarc
     1 106 4 9 3 1552 6 3 96 3 200 8072 4 5452 10 3 4143 535 6 1206 9 628 9 3 232 56 4 3 2723 6 11 21441 2645 5 2	128.842,-0.150391
     # find the score of the best hypothesis for the 3rd sentence, with chopping
     > zcat output/exp.chopping/chop/LATS/3.fst.gz | printstrings.O2 --semiring=lexstdarc
     1 106 4 9 3 1552 6 3 96 3 200 8072 4 5452 10 3 4143 535 6 1206 9 628 9 3 232 56 4 3 2723 6 11 21441 2645 5 2	130.309,1.31641



\section chopping_sseg Chopping by Explicit Source Sentence Segmentation

It is also possible to segment and translate each segment completely independently, as shown in
this example for sentence 3. Here, the original Russian sentence is
chopped into three shorter sentences which are to be translated
independently, as follows:

     # split sentence 3 into 4 separate sentences
     > awk 'NR==3' RU/RU.set1.idx | sed 's, 3 , 3 2\n1 ,g'  > RU/RU.sent3.chopped
     > cat RU/RU.sent3.chopped
     1 109 5 458 756435 1225 1358 60145 3 2
     1 12725 3 2
     1 11 3678 66369 7 1799 5 1317 2946 45 32023 3 2
     1 75 3678 1102 24 10272 28960 4 2

     # run HiFST over all segments
     > hifst.O2 --config=configs/CF.hiero.chopping --source.load=RU/RU.sent3.chopped --target.store=output/exp.chopping/sent3/hyps --hifst.lattice.store=output/exp.chopping/sent3/LATS/seg.?.fst --range=1:4

     # concatenate output lattices
     > fstconcat output/exp.chopping/sent3/LATS/seg.1.fst output/exp.chopping/sent3/LATS/seg.2.fst | fstconcat - output/exp.chopping/sent3/LATS/seg.3.fst | fstconcat - output/exp.chopping/sent3/LATS/seg.4.fst > output/exp.chopping/sent3/LATS/sent.fst

     # print output string
     > cat output/exp.chopping/sent3/LATS/sent.fst | printstrings.O2 --semiring=lexstdarc -m wmaps/wmt13.en.wmap -w 2>/dev/null
     <s> however , in the middle of the last myth , believe </s> <s> by saying , </s> <s> the cases of fraud in elections in the united states , a rare </s> <s> the deaths of a lightning strike . </s>  141.166,-12.5742

In the above example,  the language model is applied separately to the translations of each segment leading to the substrings "</s> <s>"
in the hypothesis.  A transducer can be built to remove these from the output lattice, as follows

     > mkdir tmp
     > echo -e "0\t1\t1\t1" > tmp/strip_1_2.txt
     > echo -e "1\t2\t2\t0" >> tmp/strip_1_2.txt
     > echo -e "2\t1\t1\t0" >> tmp/strip_1_2.txt
     > echo -e "2\t2\t0\t0" >> tmp/strip_1_2.txt
     > echo -e "1\t3\t2\t2" >> tmp/strip_1_2.txt
     > echo -e "3" >> tmp/strip_1_2.txt
     > awk '$2 != 1 && $2 != 2 {printf "1\t1\t%d\t%d\n", $2,$2}' wmaps/wmt13.en.wmap >> tmp/strip_1_2.txt
     > fstcompile  --arc_type=tropical_LT_tropical tmp/strip_1_2.txt | fstarcsort > tmp/strip_1_2.fst

     # apply the strip_1_2.fst transducer to the fst for sentence 3
     > fstcompose output/exp.chopping/sent3/LATS/sent.fst tmp/strip_1_2.fst | fstproject --project_output | fstrmepsilon > output/exp.chopping/sent3/LATS/sent_no12.fst

     # look at output
     > cat output/exp.chopping/sent3/LATS/sent_no12.fst | printstrings.O2 --semiring=lexstdarc -m wmaps/wmt13.en.wmap -w 2>/dev/null
     <s> however , in the middle of the last myth , believe by saying , the cases of fraud in elections in the united states , a rare the deaths of a lightning strike . </s>  141.166,-12.5742

Note however that the language model score for this hypothesis are not correct, since the language model histories cannot span translations across the chopped segments.

To fix this, the applylm tool (see \ref rescoring_lm) can
be used to remove and reapply the language model so that it spans the
source segment translations.  The following example simply removes the
language model scores from
output/exp.chopping/sent3/LATS/sent_no12.fst and then reapplies them
via composition

     > applylm.O2 --lm.load=M/lm.4g.mmap --lm.featureweights=1 --lm.wps=0.0 --semiring=lexstdarc --lattice.load=output/exp.chopping/sent3/LATS/sent_no12.fst --lattice.store=output/exp.chopping/sent?/LATS/sent_no12_rescore.fst --lattice.load.deletelmcost --range=3:3

The rescored output is written to `output/exp.chopping/sent3/LATS/sent_no12_rescore.fst`
with correctly applied language model scores.  The total translation cost is much lower (better) than when segment hypotheses are simply combined (i.e. 115.855 vs. 141.166):

     > cat output/exp.chopping/sent3/LATS/sent_no12_rescore.fst | printstrings.O2 --semiring=lexstdarc -m wmaps/wmt13.en.wmap -w 2>/dev/null
     <s> however , in the heart of the take the last myth , arguing that the rare cases of fraud in elections in the united states , the deaths of a lightning strike . </s> 	   115.855,-13.1377
