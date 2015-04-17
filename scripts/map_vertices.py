#!/usr/bin/python

# Map vertex indices from the convex hull to feature vectors

from sys import argv, stdout
from pickle import dump
from re import sub
from os import listdir, path
from itertools import count

DELTA=0.001

def equalVertex(vertex, point):
    isEqual=True
    for (vval, pval) in zip(vertex, point):
        isEqual = isEqual and abs(vval-pval) < DELTA
    return isEqual

def readMinksumFile(msfile):
    data = "".join(msfile.readlines())
    vertices = data.split("],[")
    mapped = []
    for vertex in vertices:
        fields=vertex.translate(None, "[]\n").split(",")
        mapped.append(map(float, fields)) 
    return mapped

polytopedir = argv[1]
hulldir = argv[2]

sentences = sorted([ sen.split(".")[0] for sen in listdir(argv[1]) ], key = lambda x: int(x))

mapping = {}

for sen in sentences:
    with open(path.join(polytopedir, sen + ".txt" )) as polytopefile, open(path.join(hulldir, sen + ".txt")) as hullfile:
        points = readMinksumFile(polytopefile)
        hull = readMinksumFile(hullfile)
        vertices = {}
        for (vertex, v_i) in zip(hull, count(0)):
            found = False
            for (point, p_i) in zip(points, count(0)):
                if equalVertex(vertex, point):
                    vertices[v_i]=p_i
                    found = True
                    break
            if not found:
                print "For sentence " + sen + " cannot find vertex: " + str(vertex)
        mapping[sen]=vertices
print mapping
                
