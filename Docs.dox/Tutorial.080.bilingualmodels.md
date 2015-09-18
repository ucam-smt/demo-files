Rescoring with Bilingual Neural Network Models {#bilm}
=====

**Important Note:** In order to run this tutorial you will first need to clone \ref [our local copy of nplm](https://github.com/ucam-smt), and recompile ucam-smt package following the instructions in Makefile.inc.

In the following we describe how to rescore lattices
with bilingual models as described by [\ref Devlin2014].

Bilingual Neural Network models are simple feedforward models
with word embeddings on the first layer. They are trained with
bilingual samples extracted from the aligned parallel data.
The model M/nplm.s3t4 provided with this tutorial is trained
with [\ref NPLM] on samples that have 3 source words and 4 target words:

     s1 s2 s3 t1 t2 t3 t4

t1 t2 t3 is the target history; t4 is the prediction, which is _affiliated_ to s2, the center of
the window of 3 source words. The affiliation heuristic smooths
the word alignments so that there is exactly one link per target word
and a sample can be extracted for every target word.
More details in [\ref Devlin2014].

**Important Note:** In order to generate models that are consistent with ucam-smt tools, the training samples must be numberized. As numbers are mapped to different words in source and target, but the word embeddings are shared, we offset the source integers with an arbitrarily big number, so that NPLM word embeddings discriminate source words from target words. The running example uses an offset of 10000000. This must be consistent with the bilingual model application step.

During decoding or rescoring, we also need to determine the affiliations
for the words in each rule. These can be computed on-the-fly if internal
word alignments are available. We compute the affiliations offline
and define a grammar with affiliations for each rule.

     > zcat G/grammar.affiliation.gz | grep _ | grep 1_0 | head -2
     V 3_939 1108_4 4.114964 3.335020 -2 -1 0 0 0 0 -1 5.198832 4.680031     1_0
     V 3_1600 5_569_14 4.179298 0.148420 -3 -1 0 0 0 0 -1 5.587708 6.762751  0_1_0

In rule V 3_939 1108_4,  1_0 means that word 1108 is aligned to 939 and 4 is aligned to 3.
In rule V 3_1600 5_569_14, 0_1_0 means that 5 and 14 are aligned to 3; 569 is aligned to 1600.

The following script contains a simple recipe that shows how to apply a bilingual
model to a translation lattice:

     > scripts/runBiLMRescoring.bash

The script runs various steps necessary to achieve this goal, including the usual pipeline
comprising translation, alignment and feature vector lattice generation.
These are described respectively in:
* \ref basic_trans
* \ref mert_nblist_derivations
* \ref mert_alilats

In the following we highlight the novel steps, specific to the bilingual model rescoring procedure.

**Running HiFST in affiliation mode**

Running HiFST in affiliation mode is very similar to running in alignment mode, with the
difference that instead of rules we now have one source link for each target word.
With this additional information provided in the grammar, HiFST runs in affiliation mode as so:

     > hifst.${TGTBINMK}.bin config/CF.hifst,config/CF.hifst-a,config/CF.lm --hifst.alilatsmode.type=affiliation --range=1:$M --featureweights=$FW --nthreads=15 --hifst.lattice.store=output/bilmexp/AFILATS/?.fst.gz

Affiliation Lattices have affiliation sequences on the input and words on the output. A translation hypothesis
has one or more affiliation sequences. For example:

     > printstrings.O2 --input=output/bilmexp/AFILATS.STD/1.fst.gz  --print-input-output-labels -n 10 | grep "1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2"
     1 5 6 4 2 7 7 9 9 9 12 11 10 14         1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2
     1 5 6 4 2 7 7 9 9 9 13 11 10 14         1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2

For instance, word 9967 is linked to the 10th source word in both afiliation sequences.
But word 717 is linked to the 12th word in one case, and to the 13th word in the other.

**Affiliation Lattice Disambiguation**

We disambiguate these affiliation lattices with the `disambignffst` tool.
See \ref nfdisambiguation for more details on how this tool works.

**Composition of an Affiliation lattice with a Bilingual Neural Network Model.**

For the the bilingual model application we use the `applylm` tool described
in \ref rescoring_lm.

     > applylm.${TGTBINMK}.bin --range=1:$M --nthreads=1 --lm.load=models/nplm.s3t4  --lm.featureweights=1  --lm.wps=0 --lattice.load=output/bilmexp/AFIDETLATS.0W/?.fst.gz --usebilm=yes --usebilm.sourcesize=3 --usebilm.sourcesentencefile=AR/mt02_05_tune.ara.special.idx --lattice.store=output/bilmexp/BLMONLY/?.fst.gz

The tool takes as input unweighted unambiguous lattices available in output/bilmexp/AFIDETLATS.0W/.
The output is a lattice with the bilingual model scores.
The program option `--usebilm=yes` enables bilingual composition. Note that an NPLM model is not aware of distinctions on the input between source and target; this has to be provided manually by the user with  `--usebilm.sourcesize=3`. Finally,  `--usebilm.sourcesentencefile=` points to a special version of the source file. Compare with the one used for HiFST:

    > head -1 AR/mt02_05_tune.ara.special.10first.idx
    1 10000180 10000003 10000447 10000003 10001305 10006008 10000009 10001796 10006264 10022050 10000003 10000250 2
    > head -1 AR/mt02_05_tune.ara.10first.idx
    1 180 3 447 3 1305 6008 9 1796 6264 22050 3 250 2

The difference is the aforementioned offset to ensure that NPLM distinguishes source words from target words.

**Adding the bilingual feature to the feature vector lattices**

The script has a little function `addFeatureToVECFEA` that pipes OpenFst/ucam-smt tools to add the new feature
into the feature vector lattices. Recall that a feature vector lattice contains hypotheses with their individual feature contributions.

     > FW=1.000000,0.820073,1.048347,0.798443,0.349793,0.286489,15.352371,-5.753633,-3.766533,0.052922,0.624889,-0.015877
     > printstrings.O2 --input=output/bilmexp/VECFEA/1.fst.gz  --semiring=tuplearc --tuplearc.weights=$FW -w --sparseformat
     1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2       0,9,1,55.5727,2,10.626,3,8.83496,4,-14,5,-8,6,-5,10,-8,11,29.29,12,31.3643


The highest feature index is 12. The new feature vector lattices contain the extra bilingual feature at position 13.

     > printstrings.O2 --input=output/bilmexp/VECFEA+BLM/1.fst.gz  --semiring=tuplearc --tuplearc.weights=$FW,0 -w --sparseformat
     1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2       0,10,1,55.5727,2,10.626,3,8.83496,4,-14,5,-8,6,-5,10,-8,11,29.29,12,31.3643,13,33.4465

Note that the feature weights provided to the tool need an extra 0. Otherwise, the following message would appear:

     feature vector has a larger dimensionality than the parameters. Params: 12 Features: 13

At this point, you only need to run `lmert` tool  to get a new set of weights, e.g. using as starting
parameters  $FW,0. See \ref lmert for more details.
Use `printstrings` tool to get the best hypotheses under the new weights.




