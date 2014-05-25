\page Basics
\section basic Basic Translation and Lattice Generation

The first demonstration exercise is to generate translations of
integer-mapped Russian text using the translation grammar and English
n-gram language model provided.  HiFST is configured to generate
one-best translation hypotheses as well as translation lattices.

The baseline configuration file is 

    configs/CF.baseline 

See the
comments in that file for brief explanations of the HiFST options.

The following command will translate the first 2 lines in the Russian
integer-mapped file `RU/RU.set1.idx`:

    # Run HiFST
    > mkdir log
    > hifst.O2 --config=configs/CF.baseline &> log/log.baseline

The log file output can be viewed as:

    > tail -n 11 log/log.baseline
    Fri May  9 11:04:37 2014: run.INF:=====Translate sentence 1:1 20870 2447 5443 50916 78159 3621 2
    Fri May  9 11:04:37 2014: run.INF:Loading hierarchical grammar: G/rules.shallow.gz
    Fri May  9 11:04:37 2014: run.INF:loading LM=M/lm.4g.mmap
    Fri May  9 11:04:37 2014: run.INF:Stats for Sentence 1: local pruning, number of times=0
    Fri May  9 11:04:37 2014: run.INF:End Sentence ******************************************************
    Fri May  9 11:04:37 2014: run.INF:Translation 1best is: 1 9121 384 6 2756 7 3 4144 6 1458528 1341 2 
    Fri May  9 11:04:37 2014: run.INF:=====Translate sentence 2:1 1716 20196 95123 154 1049 6778 996 9 239837 7 1799 4 2
    Fri May  9 11:04:37 2014: run.INF:Stats for Sentence 2: local pruning, number of times=0
    Fri May  9 11:04:38 2014: run.INF:End Sentence ******************************************************
    Fri May  9 11:04:38 2014: run.INF:Translation 1best is: 1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2 
    Fri May  9 11:04:38 2014: main.INF:hifst.O2 ends!

The best scoring translation hypotheses are given in integer-mapped
form, e.g. for the second Russian sentence, the best-scoring translation
hypothesis is

    run.INF:Translation 1best is: 1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2

\subsection basic_latshyps Translation Lattices and 1-Best Hypotheses

The baseline configuration file instructs HiFST to write its 1-best
translations to the output file `output/exp.baseline/hyps`
(see the `target.store=` specification in the config file).  The contents of
this file should agree with the *Translation 1best* entries in the log file
(compare these results  to above):

     > cat output/exp.baseline/hyps
     1 9121 384 6 2756 7 3 4144 6 1458528 1341 2 
     1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2 

The configuration file also directs HiFST to write translation
lattices to `output/exp.baseline/LATS/?.fst.gz` (see the
`hifst.lattice.store=` specification in the config file).  Note the
use of the placeholder '`?`' in the argument `.../LATS/?.fst.gz` . The
placeholder is replaced by the line number of sentence being
translated, e.g. so that `.../LATS/2.fst.gz` is a weighted finite state
transducer (WFST) containing
translations of the second line in the source text file.  Note also
the use of the '`.gz`' extension: when this is provided, lattices are
written as gzipped files.

The shortest path through each of these output lattices should agree
with the top-scoring hypotheses in the hyps and log files :

    > echo `zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fsttopsort | fstprint | awk '{print $3}'`
     1 9121 384 6 2756 7 3 4144 6 1458528 1341 2
    > echo `zcat output/exp.baseline/LATS/2.fst.gz | fstshortestpath | fsttopsort | fstprint | awk '{print $3}'`
     1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2

The English wordmap can be supplied to fstprint to convert from integer mapped strings to English:

    > echo `zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fsttopsort | fstprint --isymbols=wmaps/wmt13.en.wmap | awk '{print $3}'`
     <s> republican strategy of resistance to the renewal of obamas election </s>

    > echo `zcat output/exp.baseline/LATS/2.fst.gz | fstshortestpath | fsttopsort | fstprint --isymbols=wmaps/wmt13.en.wmap | awk '{print $3}'`
      <s> the leaders of the republican justified their policies need to deal with the spin on the elections . </s>

The above operations do the following:

-# `zcat` pipes the HiFST output lattice to the \ref OpenFst [Shortest Path](http://openfst.org/twiki/bin/view/FST/ShortestPathDoc) tool which produces an FST containing only the shortest path in the lattice
-# the \ref OpenFst [Topological Sort](http://openfst.org/twiki/bin/view/FST/TopSortDoc) operation renumbers the state IDs so that all arcs are links from lower to higher state IDs
-# the \ref OpenFst [fstprint](http://openfst.org/twiki/bin/view/FST/FstQuickTour#Printing_Drawing_and_Summarizing) operation reads the English wordmap, for the arc input symbols,  and traverses the input fst, writing each arc as it is encountered;  TopSort ensures these arcs are written in the correct order
-# the awk operation prints only the words on the arcs
-# wrapping everything inside echo generates a single string

To see what is produced at the various steps in the pipeline:

Input lattice:

     > zcat output/exp.baseline/LATS/1.fst.gz | fstinfo | head -6
     fst type                                          vector
     arc type                                          tropical_LT_tropical
     input symbol table                                none
     output symbol table                               none
     # of states                                       489
     # of arcs                                         1104

Shortest Path:

    > zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fstprint
    12      11      1       1       -2.609375,-2.609375
    0
    1       0       2       2       2.33047056,-2.34277344
    2       1       1341    1341    6.04568958,1.55957031
    3       2       1458528 1458528 13.4981985,2.22167969
    4       3       6       6       0.201819927,0
    5       4       4144    4144    9.78138161,0
    6       5       3       3       -0.395056069,-1.23925781
    7       6       7       7       1.79730964,0
    8       7       2756    2756    9.45967484,0.288085938
    9       8       6       6       0.892110586,-2.04589844
    10      9       384     384     7.13530731,-2.609375
    11      10      9121    9121    9.33318996,-1.26074219

(the paired weights are described in the next section (\ref basic_scores))

Topologically Sorted Shortest Path:

    > zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fsttopsort | fstprint
    0       1       1       1       -2.609375,-2.609375
    1       2       9121    9121    9.33318996,-1.26074219
    2       3       384     384     7.13530731,-2.609375
    3       4       6       6       0.892110586,-2.04589844
    4       5       2756    2756    9.45967484,0.288085938
    5       6       7       7       1.79730964,0
    6       7       3       3       -0.395056069,-1.23925781
    7       8       4144    4144    9.78138161,0
    8       9       6       6       0.201819927,0
    9       10      1458528 1458528 13.4981985,2.22167969
    10      11      1341    1341    6.04568958,1.55957031
    11      12      2       2       2.33047056,-2.34277344
    12


Toplogically Sorted Shortest Path, with English words replacing the arc input symbols

    > zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fsttopsort | fstprint --isymbols=wmaps/wmt13.en.wmap
    0       1       <s>     1       -2.609375,-2.609375
    1       2       republican      9121    9.33318996,-1.26074219
    2       3       strategy        384     7.13530731,-2.609375
    3       4       of      6       0.892110586,-2.04589844
    4       5       resistance      2756    9.45967484,0.288085938
    5       6       to      7       1.79730964,0
    6       7       the     3       -0.395056069,-1.23925781
    7       8       renewal 4144    9.78138161,0
    8       9       of      6       0.201819927,0
    9       10      obamas  1458528 13.4981985,2.22167969
    10      11      election        1341    6.04568958,1.55957031
    11      12      </s>    2       2.33047056,-2.34277344
    12


Note that loading the English wordmap can be time consuming due to its
size.  Ideally, in processing multiple translation hypotheses, the
wordmap should be loaded only once, rather than once for each
sentence.  The FST Archive (FAR) command line tools (in the \ref OpenFst FAR [extensions](http://openfst.org/twiki/bin/view/FST/FstExtensions))
will do this:

    > farcompilestrings --entry_type=line output/exp.baseline/hyps | farprintstrings --symbols=wmaps/wmt13.en.wmap
    <s> republican strategy of resistance to the renewal of obamas election </s>
    <s> the leaders of the republican justified their policies need to deal with the spin on the elections . </s>

\subsection basic_nbest N-Best Lists

The `printstrings` tool provided with this tutorial combines the above operations into a single programme.  It also can print the top-N hypotheses, as the following example shows

    > zcat output/exp.baseline/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc --nbest=10 --unique -w 2>/dev/null
    1 9121 384 6 2756 7 3 4144 6 1458528 1341 2 	    57.4705,-8.03809
    1 3 9121 384 6 2756 7 3 4144 6 1458528 1341 2 		    57.5366,-8.66992
    1 9121 384 6 2756 7 3 4144 6 159312 42 1341 2 		    57.7029,-8.49512
    1 3 9121 384 6 2756 7 3 4144 6 159312 42 1341 2 	    57.769,-9.12695
    1 9121 384 2756 7 3 4144 6 1458528 1341 2     59.5391,-6.32422
    1 3 9121 384 2756 7 3 4144 6 1458528 1341 2   59.6052,-6.95605
    1 9121 384 2756 7 3 4144 6 159312 42 1341 2   59.7715,-6.78125
    1 3 9121 1132 384 4144 6 1458528 1341 2   59.8094,1.74512
    1 3 9121 384 2756 7 3 4144 6 159312 42 1341 2	59.8376,-7.41309
    1 3 9121 1132 384 3 4144 6 1458528 1341 2   59.8382,-0.804688

With the English wordmap,  `printstrings` will map the integer representation to English text:

    > zcat output/exp.baseline/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc --nbest=10 --unique -w -m wmaps/wmt13.en.wmap 2>/dev/null
    <s> republican strategy of resistance to the renewal of obamas election </s> 	      57.4705,-8.03809
    <s> the republican strategy of resistance to the renewal of obamas election </s>      57.5366,-8.66992
    <s> republican strategy of resistance to the renewal of obama 's election </s> 	      57.7029,-8.49512
    <s> the republican strategy of resistance to the renewal of obama 's election </s>    57.769,-9.12695
    <s> republican strategy resistance to the renewal of obamas election </s>     59.5391,-6.32422
    <s> the republican strategy resistance to the renewal of obamas election </s>	59.6052,-6.95605
    <s> republican strategy resistance to the renewal of obama 's election </s> 	59.7715,-6.78125
    <s> the republican opposition strategy renewal of obamas election </s> 		59.8094,1.74512
    <s> the republican strategy resistance to the renewal of obama 's election </s>		59.8376,-7.41309
    <s> the republican opposition strategy the renewal of obamas election </s> 		59.8382,-0.804688

\subsection basic_scores Scores, Costs, and Semirings

HiFST follows the formalism in which rule probabilities are represented as arc weights (see Section 2 of [\ref deGispert2010]).

A rule with probability *p* is represented as a negative log probability, i.e.

     X -> < A , B > / - log(p)

with n-gram language model scores encoded similarly, 
i.e. as costs  -log P(w|h)  
for word *w* with LM history *h*. Costs are accumulated at the
path level, so that the shortest path through the output FSA accepts
the highest scoring hypothesis under the translation grammar and the
language model.  Hence the use of \ref OpenFst [ShortestPath](http://openfst.org/twiki/bin/view/FST/ShortestPathDoc) to extract the best scoring
hypothesis under the tropical semiring.

The \ref OpenFst [Push](http://openfst.org/twiki/bin/view/FST/PushDoc)  operation can be used to accumulate weights at the path level within the shortest path fst:

     > zcat output/exp.baseline/LATS/1.fst.gz | fstshortestpath | fsttopsort | fstpush --push_weights --to_final | fstprint --isymbols=wmaps/wmt13.en.wmap
     0       1       <s>     1
     1       2       republican      9121
     2       3       strategy        384
     3       4       of      6
     4       5       resistance      2756
     5       6       to      7
     6       7       the     3
     7       8       renewal 4144
     8       9       of      6
     9       10      obamas  1458528
     10      11      election        1341
     11      12      </s>    2
     12      57.4707222,-8.03808594

HiFST uses the lexicographic semiring (see [\ref Roark2011]) of two tropical
weights to keep track of the translation score and the language model score.

The lexicographic semiring is a pair of real-valued weights, and in
this application the first component, 54.4707222, contains the sum of the
translation grammar scores and the language model.  The second component,
-8.03808594, is the translation grammar score alone;
 see Section 5.1 of [\ref Allauzen2014].
The lexicographic semiring is such that these scores
are computed correctly at the path level:  

- The cost of the shortest path found by [ShortestPath](http://openfst.cs.nyu.edu/twiki/bin/view/FST/ShortestPathDoc) is that of the best hypothesis under the sum of the translation grammar and language model scores
- In the lexicographic semiring, when the path weight is pushed to the final state: 
    - the first weight component is the correct combined translation and language model score
    - the second weight component is the best translation score over all possible derivations that could have generated this hypothesis

One advantage of this representation is that it is easy to remove the language
model score prior to [rescoring the lattice with a new language
model](#lmrescore) simply by mapping the second component of the
lexicographic weight to a plain tropical weight prior to composition
with a weighted finite state automaton (WFSA) containing the new language model scores.  

- N.B. Also see (\ref lmert_veclats_tst) 

\subsection basic_toplevelpruning Admissible pruning / top-level pruning

HiFST can prune translation lattices prior to saving them to disk.  Pruning is
done using the \ref OpenFst [Prune](http://openfst.cs.nyu.edu/twiki/bin/view/FST/PruneDoc) operation.
Pruning in this case is admissible, since it is
performed after translation and language model scores have been
completely applied.  Low-scoring hypotheses are discarded, but no search
errors are introduced by this pruning.  Top-level pruning is described in detail in Section 2.2.2, [\ref deGispert2010].

Top-level pruning is controlled by the `--hifst.prune` option.  In the
previous examples, `--hifst.prune` was set to 9. If we use the default
(3.40282347e+38), then the output lattice size becomes very large. For
example, compare lattices in `exp1/` generated with `prune=9` vs.
unpruned lattices in `exp2/`:

    > hifst.O2 --config=configs/CF.baseline.outputnoprune &> log/log.baseline.outputnoprune
    > du -sh output/exp.baseline/LATS/1.fst.gz output/exp.baseline.outputnoprune/LATS/1.fst.gz
    8.0K  output/exp.baseline/LATS/1.fst.gz
    56K   output/exp.baseline.outputnoprune/LATS/1.fst.gz
    > du -sh output/exp.baseline/LATS/2.fst.gz output/exp.baseline.outputnoprune/LATS/2.fst.gz
    84K output/exp.baseline/LATS/2.fst.gz
    3.8M	output/exp.baseline.outputnoprune/LATS/2.fst.gz

The \ref OpenFst
[fstinfo](http://openfst.org/twiki/bin/view/FST/FstQuickTour#Printing_Drawing_and_Summarizing)
command also indicates much larger outputs:

    > zcat output/exp.baseline/LATS/2.fst.gz | fstinfo | grep \#
    # of states                                       3312
    # of arcs                                         11365
    # of final states                                 1
    # of input/output epsilons                        0
    # of input epsilons                               0
    # of output epsilons                              0
    # of accessible states                            3312
    # of coaccessible states                          3312
    # of connected states                             3312
    # of connected components                         1
    # of strongly conn components                     3312

    > zcat output/exp.baseline.outputnoprune/LATS/2.fst.gz | fstinfo | grep \#
    # of states                                       39270
    # of arcs                                         584446
    # of final states                                 1
    # of input/output epsilons                        0
    # of input epsilons                               0
    # of output epsilons                              0
    # of accessible states                            39270
    # of coaccessible states                          39270
    # of connected states                             39270
    # of connected components                         1
    # of strongly conn components                     39270


The unpruned lattices are much bigger, and contain many translation
hypotheses, although the top scoring hypotheses should be unchanged
by this form of pruning, as is the case in this example:

    > head output/exp.baseline/hyps output/exp.baseline.outputnoprune/hyps
    ==> output/exp1/hyps <==
    1 9121 384 6 2756 7 3 4144 6 1458528 1341 2 
    1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2 

    ==> output/exp.baseline.outputnoprune/hyps <==
    1 9121 384 6 2756 7 3 4144 6 1458528 1341 2 
    1 3 1119 6 3 9121 1711 63 355 85 7 369 24 3 13907 17 3 628 5 2 


\subsection multithread Multithreading 

(* note that the timing results here are illustrative only.)

HiFST uses
[Boost.Thread](http://www.boost.org/doc/libs/1_38_0/doc/html/thread.html)
to enable multithreading.  This is disabled by default, but can enabled using
the flag `--nthreads=N` .  If set, each source language sentence is
translated simultaneously on its own thread (trimmed to the number of
CPUs available).  The translation grammar and language model are kept in
shared memory.

To see the effects of multithreading on speed and memory use,
the baseline configuration is run over the first twenty sentences without multithreading:

     > time hifst.O2 --config=configs/CF.baseline --range=1:20 

Processing time is 140 seconds and maximum memory use is about 0.3GB.  
In the same decoder configuration but with 2 threads

     > time hifst.O2 --config=configs/CF.baseline --range=1:20 --nthreads=2

processing time is reduced to 90 seconds with maximum memory use of about 0.5GB.

In these examples, both the LM and translation grammar are relatively
small, and so there is not a great deal of gain from keeping them in
shared memory.   But in larger tasks,  multithreading can be a significant advantage.

\subsection server Client-Server Mode (Experimental)

HiFST can run in server mode. 

     > hifst.O2 --config=configs/CF.baseline.server &> log/log.server &
     > pid=$! # catch the server pid 

Note that in this particular configuration, both source and target wordmaps are loaded,
so Hifst can read tokenized Russian text and produce tokenized English translations
(see options `--prepro.wordmap.load` and `--postpro.wordmap.load`).
Also, to ensure that CYK parser never fails, out of vocabulary (OOV) words must be detected (`--ssgrammar.addoovs.enable`) and sentence markers (`<s>`,`</s>`)
have to be added on the fly, as the shallow grammar relies on them (i.e. `S 1 1`).

With the `hifst-client.O2` binary, we can read Russian tokenized text (`RU/RU.tune`) and submit translation requests to the server.
The output is stored in a file specified by the client tool (`--target.store`).

    > sleep 60 # make sure to wait for the server to finish loading, otherwise clients will fail
    > hifst-client.O2 --config=configs/CF.baseline.client --range=200:5:300 --target.store=output/exp.clientserver/translation1.txt &> log/log.client1 &
    # Connect to localhost, port=1205 and translate a bunch of sentences. Lets do this in background, just for fun
    # Note that the localhost setting is in the config file; this can point to another machine, of course
    > pid2=$! 

    > hifst-client.O2 --config=configs/CF.baseline.client --range=1:50,100,1300 --target.store=output/exp.clientserver/translation2.txt &> log/log.client2 &
    # In the meantime, we request another 52 translations...
    > wait $pid2

    > kill -9 $pid      
    # We are finished -- kill the server 

    > head -5 output/exp.clientserver/translation2.txt
    parliament supports amendment giving freedom tymoshenko
    amendment , which led to a liberation located imprisoned former prime minister was rejected during second reading bill mitigating sentences for economic offences .
    sentence still ultimate ; the court will review appeal tymoshenko in december .
    proposal cancel article 365 criminal-procedural codex whereby former prime minister was convicted was supported 147 members parliament .
    winning libya
