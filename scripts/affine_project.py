#!/usr/bin/python

#Picking utov and wip as features to explore

from sys import stdin,argv

params = list(map(float,argv[1].split(",")))

#Hack because Minksum starting point is 1,1,1
params[1]=params[1]-1
params[3]=params[3]-1

vertices = []

print("[")
for line in stdin:
    features = list(map(float,line.split()))
    project = []
    initial = 0.0
    for (val, param) in zip(features, params):
        initial = initial + val*param
    project.append(initial)
    project.append(features[1])
    project.append(features[3])
    output = []
    for val in project:
        output.append("{0:.4f}".format(val*-1))
    vertices.append("["+ ",".join(output)+"]")
print ("["+",".join(vertices)+"]")
print ("]")

    
