MERT - Features Only {#mert}
============================

This section describes how to generate N-Best lists of features for
use with MERT
[[Och 2003](http://aclweb.org/anthology/P/P03/P03-1021.pdf)].

\section mert_nblists  HiFST_nbestformert

A script named `scripts/HiFST_nbestformert` is provided which can generate hypotheses and feature vectors
that can be used by MERT. We use N-Best lists of depth N = 100 , set by
the `prunereferenceshortestpath=` option in `configs/CF.mert.alilats.nbest`.

For this tutorial, the configuration
files specify multithreading, and N-Best lists will be generated only
for the first 2 sentences in RU/RU.tune.idx ; the script can be edited
to process the entire file.   The output is written to the file `output/exp.mert/nbest/nbest.list`.

    > scripts/HiFST_nbestformert
    > head -2 output/exp.mert/nbest/nbest.list; echo ....; tail -2 output/exp.mert/nbest/nbest.list
    1 ||| parliament does not support the amendment , which gives you the freedom of tymoshenko |||	    62.5442	10.8672	8.3936 -16.0000 -8.0000 -5.0000 0.0000 -1.0000 0.0000 -7.0000 16.3076 40.5293
    1 ||| the parliament does not support the amendment , which gives you the freedom of tymoshenko ||| 63.1159	12.8613	8.7959 -17.0000	-8.0000	-5.0000	0.0000 -1.0000 0.0000 -7.0000 17.0010 43.9482
    ....
    2 ||| the amendment , which has led to the release of which is in jail , former prime minister , was rejected during the second reading of the bill to ease penalty for economic offences . ||| 135.8217 24.0928 50.8281 -37.0000 -21.0000 -12.0000 0.0000 -1.0000 0.0000 -20.0000 100.6992 111.6357
    2 ||| the amendment , which would have led to the release of which is in the jail of former prime minister , was rejected during the second reading of the bill to ease sentences for economic offences . |||	 145.1169	  23.7305  41.4756  -39.0000	   -23.0000	   -14.0000 0.0000 -1.0000 0.0000 -22.0000 93.0488 107.7188

The steps carried out in the `HiFST_nbestformert` script are described next.

\section mert_hyps 1. Hypotheses for MERT

(note that this step is also done in \ref lmert)

- Input:
  - `RU/RU.tune.idx` -- tuning set source language sentences
  - `G/rules.shallow.vecfea.all.gz` -- translation grammar
  - `M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap` -- target language model
  - language model and translation grammar feature weights (see configs/CF.mert.hyps)
- Output
  - `output/exp.mert/LATS/?.fst.gz` -- word lattices (WFSAs), determinized and minimized

This step runs HiFST in the usual way to generate a set of translation
hypotheses which will be used in MERT.  Note that M (the number of
sentences to translate) is set to 5, just to make the tutorial steps
run quickly.

    > M=5
    # replace by M=1502 to process the entire tuning set
    > hifst.O2 --config=configs/CF.mert.hyps --range=1:$M &> log/log.mert.hyps

In this configuration, the grammar feature weights and the language
model feature weights are applied on-the-fly to the grammar and
language model as they are loaded.  This allows feature vector weights
to be changed at each iteration of MERT.  This behaviour is specified
through the following options in the CF.mert.hyps file, where we use
the parameters from the baseline system:

    [lm]
    load=M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap
    featureweights=1.0
    # Note that for only one language model, this parameter will always be set to 1.
    # If there are multiple language models, the language model weights will be updated
    # after each iteration of MERT

    [grammar]
    load=G/rules.shallow.vecfea.all.gz
    featureweights=0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136
    # Note that this parameter vector should be updated after each iteration of MERT
    # Updated versions can be provided via command line arguments

The translation grammar has its rules with unweighted feature vectors:

    > zcat G/rules.shallow.vecfea.all.gz | head -n 3
    V 3 4 0.223527 0.116794 -1 -1 0 0 0 0 -1 1.268789 0.687159
    V 3 4_3 3.333756 0.338107 -2 -1 0 0 0 0 -1 1.662178 3.363062
    V 3 8 3.74095 3.279819 -1 -1 0 0 0 0 -1 3.741382 2.271445

The output lattices in `output/exp.mert/LATS` are acceptors containing
word hypotheses, with weights in the form of the lexicographic
semiring as described earlier.

    > zcat output/exp.mert/LATS/1.fst.gz | fstinfo | head -n 2
    fst type                                          vector
    arc type                                          tropical_LT_tropical

    > zcat output/exp.mert/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc -m wmaps/wmt13.en.all.wmap -w 2>/dev/null
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>	43.093,-19.4512


\section mert_nblist_derivations 2. Guided Translation / Forced Alignment

- Input:
   - `RU/RU.tune.idx` -- tuning set source language sentences
   - `G/rules.shallow.all.gz` -- translation grammar
   - `M/interp.4g.arpa.newstest2012.tune.corenlp.ru.idx.union.mmap` -- target language model
   - `output/exp.mert/LATS/?.fst.gz` -- word lattices (WFSAs), determinized and minimized (from \ref mert_hyps)
- Output:
   - `output/exp.mert/nbest/ALILATS/?.fst.gz` -- transducers mapping derivations to translations (e.g. Fig. 7, [\ref deGispert2010])

Alignment is the task of finding the derivations (sequences of rules)
that can produce a given translation.  HiFST performs alignment via
constrained translation (see Section 2.3, [\ref deGispert2010] for a
detailed description).  This command runs HiFST in alignment mode:

    > hifst.O2 --config=configs/CF.mert.alilats.nbest --range=1:$M &> log/log.mert.alilats.nbest

In alignment mode, HiFST constructs *substring acceptors* (see Fig. 8,
[\ref deGispert2010]). These are constructed for each sentence as follows:

- the lattice from Step 1 is loaded by HiFST
- an N-Best list in the form of a WFSA is extracted (using `fstshortestpath`) under the translation and language model score from Step 1
- weights are removed from N-Best WFSA
- the WFSA is transformed to a substring acceptor

The translation grammar is applied in the usual way, but the
translations are intersected with the substring acceptors so that only
translations in the N-Best lists are retained.  This generates every
possible derivation of each N-Best list entry.

This behaviour is specified by the following config file parameters:

    [referencefilter]
    load=output/exp.mert/LATS/?.fst.gz
    # perform alignment against these reference lattices containing initial hypotheses
    prunereferenceshortestpath=100
    # on loading the reference lattices, transform them to n-best lists prior to alignment.
    # uses fstshortestpath

Note that application of the substring acceptors is very efficient;
and this alignment step should be much faster than the translation
operation of Step 1.
The alignment lattices (referred to as ALILATS) map rule sequences
(derivations) to translation hypotheses.  Weights remain in
lexicographic semiring form.

    > zcat output/exp.mert/nbest/ALILATS/1.fst.gz | fstinfo | head -n 2
    fst type                                          vector
    arc type                                          tropical_LT_tropical

Individual rules are identified by their line number in the translation grammar file.  A rule map can be created as

    > zcat G/rules.shallow.all.gz | awk 'BEGIN{print "0\t0"}{printf "%s-><%s,%s>\t%d\n", $1, $2, $3, NR}'  > G/rules.shallow.all.map


The ALILATS transducers are not determinised: they contain every possible derivation
for each N-Best list entry.  The following
example prints some of the alternative derivations of the top-scoring
hypothesis:

    > zcat output/exp.mert/LATS/1.fst.gz | fstshortestpath > tmp/1.fst # properly, should remove arcweights
    > zcat output/exp.mert/nbest/ALILATS/1.fst.gz | fstcompose - tmp/1.fst | fstproject | printstrings.O2 --nbest=10 --semiring=lexstdarc -m G/rules.shallow.all.map 2>/dev/null | head -n 2
    S-><1,1> V-><3526,50> X-><V,V> S-><S_X,S_X> V-><28847,245> X-><10_1278_V,135_20_103_3_V> S-><S_X,S_X> V-><3_64570,4_25_1145_48> X-><V,V> S-><S_X,S_X> V-><1857,3_425_6> X-><V_7786,V_23899> S-><S_X,S_X> X-><2,</s>> S-><S_X,S_X>
    S-><1,1> V-><3526,50> X-><V,V> S-><S_X,S_X> V-><28847,245> X-><10_1278_V,135_20_103_3_V> S-><S_X,S_X> V-><3_64570,4_25_1145_48> X-><V,V> S-><S_X,S_X> V-><1857,3_425_6> X-><V,V> S-><S_X,S_X> V-><7786,23899> X-><V,V> S-><S_X,S_X> X-><2,</s>> S-><S_X,S_X>

The order of the rules in these rule sequences correspond to HiFST's
bottom-up (left-to-right) CYK grid structure.  Rule IDs are added as
input symbols to the component WFSTs in the RTN following the
translation rule (with its non-terminals).  This leads to the
bottom-up ordering after Replacement.


\section mert_alilats 3. Hypotheses with Unweighted Feature Vectors

- Input:
   - `G/rules.shallow.vecfea.all.gz` -- translation grammar, rules with (unweighted) feature vectors
   - `output/exp.mert/nbest/ALILATS/?.fst.gz` -- transducers mapping derivations to translations, for n-best entries (from \ref mert_nblist_derivations)
   - language model and translation grammar feature weights (see `configs/CF.mert.vecfea.nbest`)
- Output:
   - `output/exp.mert/lats/VECFEA/?.nbest.gz` -- N-best hypotheses
   - `output/exp.mert/lats/VECFEA/?.vecfea.gz` -- N-best unweighted features

The alilats2splats tool transforms ALILATS alignment lattices
(transducers) to sparse vector weight lattices; see Section 2.3.1, [\ref deGispert2010] for a detailed explanation.

    > alilats2splats.O2 --config=configs/CF.mert.vecfea.nbest --range=1:$M &> log/log.mert.nbest

The output is written to two sets of files:  

N-best lists:

     > head -n 2 output/exp.mert/nbest/VECFEA/1.nbest
     <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>	43.0904
     <s> the parliament does not support the amendment , which gives you the freedom of tymoshenko </s>	43.1757

Vecfea files:

     > head -n 2 output/exp.mert/nbest/VECFEA/1.vecfea
     62.5442 10.8672 8.3936 -16.0000 -8.0000 -5.0000 0.0000  -1.0000 0.0000  -7.0000 16.3076 40.5293
     63.1159 12.8613 8.7959 -17.0000 -8.0000 -5.0000 0.0000  -1.0000 0.0000  -7.0000 17.0010 43.9482

- Line `n` in the nbest list is the `n-th' translation hypotheses, as ranked under the combined translation and language model scores.
- Line `n` in the vecfea file is a vector obtained by summing the unweighted feature vectors of each rule in the best derivation of the `n-th` hypothesis

The alilats2splats tool works as follows:

- The translation grammar with (unweighted) feature vectors is loaded
- a Rule Flower acceptor, R, is created.  This is an acceptor for rule sequences that applies vector weights (specifically, the feature vector for each rule).  See Fig. 9 of [\ref deGispert2010] for an example and an explanation.
- For each source sentence, the ALILATS derivation-to-translation transducer from Step 2 is loaded, and its weights are removed.  Call this T_u
- The unweighted derivations-to-translation trandsducer T_u is composed with the Rule Flower acceptor R under the  tropical sparse tuple weight semiring with the same feature vectors as are used to generate the translation.  
- The feature vector for the best scoring derivation for every translation is found as Determinise(Project_output(R o T_u) )
- Language model scores M_1, ..., M_m are applied (again in the  tropical sparse tuple weight semiring, so that each score ends up in a separate element in the vector) as Determinise(Project_output(R o T_u) ) o M_1 o ... o M_m

Writing of N-Best lists and features is
controlled by the `sparseweightvectorlattice` options `storenbestfile`
and `storefeaturefile`:

    [sparseweightvectorlattice]
    loadalilats=output/exp.mert/nbest/ALILATS/?.fst.gz
    storenbestfile=output/exp.mert/nbest/VECFEA/?.nbest
    storefeaturefile=output/exp.mert/nbest/VECFEA/?.vecfea
    wordmap=wmaps/wmt13.en.all.wmap

With the wordmap specified, the output of alilats2splats is in readable form in the
target language. Note that the sentence boundary symbols and the combined
translation and language model score appear in the nbest file.
The N-best lists have the format
- wordindex1 wordindex2 ... translation_score

The relationship of feature vectors and scores at the hypothesis level is as follows:
- Suppose there are m language models, with weights s_1 ...,s_m .
  - These weights are specified by the HiFST parameters `lm.featureweights=s_1,s_2,..,s_m`
- Suppose there are n dimensional feature vectors for each rule,
  - The weights to be applied are specified by the HiFST parameters `grammar.featureweights=w_1,..,w_n`
- A feature weight vector is formed as P = [s_1 ... s_m w_1 ... w_n]
- A translation hypothesis e has a feature vector F(e) = [lm_1(e) ... lm_m(e) f_1(e) ... f_n(e)]
  - lm_i(e): the i-th language model score for e
  - f_j(e): j-th grammar feature (see Section 3.2.1, [\ref deGispert2010])
- The score of translation hypothesis e can be found as S(e) = F(e) . P (dot product)

Each line k in the feature file has the format
- lm_1(e_k) ... lm_m(e_k) f_1(e_k) ... f_n(e_k)

which are the unweighted feature values for the k-th hypothesis, e.g.

     > head -n 2 output/exp.mert/nbest/VECFEA/1.vecfea
     62.5442 10.8672 8.3936 -16.0000 -8.0000 -5.0000 0.0000  -1.0000 0.0000  -7.0000 16.3076 40.5293
     63.1159 12.8613 8.7959 -17.0000 -8.0000 -5.0000 0.0000  -1.0000 0.0000  -7.0000 17.0010 43.9482

and the translation_score in line k is F(e_k) . P

    > head -n 2 output/exp.mert/nbest/VECFEA/1.nbest
    <s> parliament does not support the amendment , which gives you the freedom of tymoshenko </s>	43.0904
    <s> the parliament does not support the amendment , which gives you the freedom of tymoshenko </s>	43.1757
