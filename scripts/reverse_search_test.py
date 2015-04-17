#!/usr/bin/python

# Sanity test for the reverse search. Tests parameters given over the std input.
# For each paramter the N-best for each sentence is reranked. If a top scoring
# hypotheses does not match the results of reverse search then it is reported.

from sys import argv, stdin
from itertools import count
from subprocess import Popen, PIPE
from os import path
from copy import copy
from operator import itemgetter

mappingfilename = argv[1]
featuredir = argv[2]
w0String = argv[3]

with open(mappingfilename) as mappingfile:
    mapping = eval(mappingfile.readline())

w0=map(float, w0String.split(","))

w0[1] = w0[1] - 1
w0[3] = w0[3] - 1

features = {}
for sen in mapping.keys():
    featurefilename = path.join(featuredir, sen + ".vecfea.gz")
    cmd = "cat " + featurefilename + " | gunzip"
    p = Popen(cmd, stdout=PIPE, shell=True)
    featurevecs = []
    for line in p.stdout:
        featurevec = map(float, line.split())
        featurevecs.append(featurevec)
    features[sen] = featurevecs
    
for (line, lineno) in zip(stdin, count(1)):
    fields = [field.translate(None, "[]") for field in line.split(":")]
    projparams = map(float, fields[2].split(","))
    scalefac = projparams[0]
    if scalefac < 0.0:
        continue
    print "Sanity check for parameter " + str(lineno)
    projparams = map(lambda x: x/scalefac, projparams)
    newparam = copy(w0)
    newparam[1] = projparams[1] + newparam[1]
    newparam[3] = projparams[2] + newparam[3]
    mapped = [mapping[str(sen)][vertex] for (sen,vertex) in zip(count(1), map(int, fields[0].split(",")))]
    for sen in sorted(features.keys(), key = lambda x : int(x)):
        featurevecs = features[sen]
        results = []
        for (featurevec, h) in zip(featurevecs, count(0)):
            dotprod = 0.0
            for (val, param) in zip(featurevec, newparam):
                dotprod = dotprod + val*param
            results.append((h, dotprod))
        results.sort(key = itemgetter(1))
        if results[0][0] != mapped[int(sen) -1]:
            for i in range(len(results)):
                if results[i][0] == mapped[int(sen) -1]:
                    print "\tDiscrepancy! For input sentence " + sen + " featue vector " + str(i+1) + " is the top scorer"
    
