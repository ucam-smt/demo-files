#!/bin/bash

SETSIZE=150

mkdir -p output/exp.mert/polytope
for i in `seq 1 $SETSIZE`; do cat output/exp.mert/nbest/VECFEA/$i.vecfea.gz | gunzip | ./scripts/affine_project.py 1.0,0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136 > output/exp.mert/polytope/$i.txt;done 

mkdir -p output/exp.mert/hull
for i in `seq 1 $SETSIZE`; do cat output/exp.mert/polytope/$i.txt | $MINK_SUM/convexHull -d > output/exp.mert/hull/$i.txt;done

for i in `seq 1 $SETSIZE`; do cat output/exp.mert/hull/$i.txt ;done | awk 'BEGIN{print "["}{if(NR < 1502) {print $1","} else {print $1}} END{print "]"}' > output/exp.mert/minksumin.txt

pushd .
mkdir -p output/exp.mert/reverse_search
cd output/exp.mert/reverse_search
$MINK_SUM/minkSumForkGrid -c -n 12  < ../minksumin.txt 
popd

scripts/map_vertices.py output/exp.mert/polytope output/exp.mert/hull > output/exp.mert/mapping.txt

cat output/exp.mert/reverse_search/result.* |  scripts/reverse_search_test.py output/exp.mert/mapping.txt output/exp.mert/nbest/VECFEA 1.0,0.697263,0.396540,2.270819,-0.145200,0.038503,29.518480,-3.411896,-3.732196,0.217455,0.041551,0.060136 > log/log.reverse.search.sanity
