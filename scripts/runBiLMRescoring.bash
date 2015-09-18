# This is a toy example for bilingual model rescoring with 10 sentences.
# The script shows how to score lattices with the bilingual model and
# then incorporate these scores into feature vector lattices, which can be
# then tuned with Lattice MERT to get new DECODER+bilingual model weights.

FW=1.000000,0.820073,1.048347,0.798443,0.349793,0.286489,15.352371,-5.753633,-3.766533,0.052922,0.624889,-0.015877
M=10

#### Translation:
hifst.${TGTBINMK}.bin configs/CF.hifst.bilm,configs/CF.hifst-lm.bilm --range=1:$M --featureweights=$FW --nthreads=15 --hifst.lattice.store=output/bilmexp/LATS/?.fst.gz

#### Alignment
hifst.${TGTBINMK}.bin configs/CF.hifst.bilm,configs/CF.hifst-a.bilm,configs/CF.hifst-lm.bilm --range=1:$M --featureweights=$FW --nthreads=15 --hifst.lattice.store=output/bilmexp/ALILATS/?.fst.gz

#### Veclats
alilats2splats.${TGTBINMK}.bin --config=configs/CF.hifst-lm.bilm,configs/CF.alilats2splats.bilm --range=1:$M --featureweights=$FW --nthreads=8


#### Affiliation:
hifst.${TGTBINMK}.bin configs/CF.hifst.bilm,configs/CF.hifst-a.bilm,configs/CF.hifst-lm.bilm --hifst.alilatsmode.type=affiliation --range=1:$M --featureweights=$FW --nthreads=15 --hifst.lattice.store=output/bilmexp/AFILATS/?.fst.gz

lexmap.${TGTBINMK}.bin --range=1:$M --action=lex2std --input=output/bilmexp/AFILATS/?.fst.gz --output=output/bilmexp/AFILATS.STD/?.fst.gz


#### Disambiguation
disambignffst.O2.bin --range=1:$M --determinize-output=yes --input=output/bilmexp/AFILATS.STD/?.fst.gz --output=output/bilmexp/AFIDETLATS/?.fst.gz

#### Remove weights:

mkdir -p  output/bilmexp/AFIDETLATS.0W/; for k in `seq 1 $M`; do zcat output/bilmexp/AFIDETLATS/$k.fst.gz | fstmap --map_type=rmweight | gzip > output/bilmexp/AFIDETLATS.0W/$k.fst.gz ; done

#### Apply bilingual model

if [ ! -e M/nplm.s3t4 ]; then   ### Probably the model has not been unzipped yet.
    echo "Uncompressing the NN model..."
    gunzip M/nplm.s3t4.gz
fi
applylm.${TGTBINMK}.bin --range=1:$M --nthreads=1 --lm.load=M/nplm.s3t4  --lm.featureweights=1  --lm.wps=0 --lattice.load=output/bilmexp/AFIDETLATS.0W/?.fst.gz --usebilm=yes --usebilm.sourcesize=3 --usebilm.sourcesentencefile=AR/mt02_05_tune.ara.special.10first.idx --lattice.store=output/bilmexp/BLMONLY/?.fst.gz

#### Finally, add to the feature vector lattices in a rather convoluted way.
#### vecmap moves the bilm contribution to feature 13 and this allows a composition with the original vecfea file, which adds this extra feature
addFeatureToVECFEA() {
    # VECFEA lattices don't have DR/OOVs, they are epsilons, so we need to relabel them first.
    echo -e "999999999 0\n999999998 0" >relabelpairs
    # Careful with vecmap tool: k=12 actually means it will be added in column 13.
    export FEATURECOLUMN=12
    TMPD=tmp
    mkdir -p $TMPD output/bilmexp/VECFEA+BLM
    for k in `seq 1 $M`; do
        zcat output/bilmexp/BLMONLY/$k.fst.gz  | vecmap.${TGTBINMK}.bin --tuplearc=true  --k=$FEATURECOLUMN | fstproject --project_output | fstrelabel --relabel_ipairs=relabelpairs --relabel_opairs=relabelpairs | fstrmepsilon | fstdeterminize| fstarcsort > $TMPD/$k.fst
        zcat output/bilmexp/VECFEA/$k.fst.gz | fstcompose  - $TMPD/$k.fst | gzip > output/bilmexp/VECFEA+BLM/$k.fst.gz
        rm $TMPD/$k.fst
    done
}

addFeatureToVECFEA


#### You are ready to run Lattice MERT, with an extra weight, e.g. set to 0:
# FW2=$FW,0
# lmert.${TGTBINMK}.bin --int_refs=intrefs/ref.idx.1 --range=1:$M \
#     --input=output/bilmexp/VECFEA+BLM/?.fst.gz --initial_params=$FW2 --random_seed=17 \
#     --write_params=output/bilmexp/param.1 --nthreads=15
#### Note: to get sensible parameters, this should run over a much bigger devset
#### Use the new weights with printstrings to get the 1-best on this set or on any other.

