\subsection lmbr Lattice Minimum Bayes Risk Decoding

For a detailed discussion of LMBR, see Chapters 7 and 8 in [\ref BlackwoodPhD].

LMBR is a decoding procedure, based on the following:

- Evidence space: a lattice (WFSA) containing weighted translations produced by the SMT system.
    - N-gram posterior distributions, with pathwise posteriors, are extracted from this WFSA.
- The hypotheses space: an unweighted lattice (FSA) containing hypotheses to be rescored.

The following steps are carried out in LMBR decoding:

1. The evidence space is normalised after applying a grammar scale factor (`--alpha=`). Scaling is done by the \ref OpenFst [Push](http://www.openfst.org/twiki/bin/view/FST/PushDoc) towards final states, and setting the final state probability to 1.0.
3. N-grams are extracted from the hypothesis space.
4. N-gram path-posterior probabilities are computed over the evidence space using a modified Forward procedure (see \ref Blackwood2010)
5. Cyclic WFSAs are built to represent posterior probability distribution  of each n-gram order and compose with the original hypotheses space. A word insertion penalty (`--wps=`) is also included in the costs of the cyclic WFSAs.
6. Risk is computed through a sequence of compositions.
7. The result for LMBR decoding is a WFSA; each weighted path represents a hypothesis and its risk.

The weighted hypothesis space can be save as a WFSA, or the minimum risk hypothesis can be
generated via the \ref OpenFst 
[ShortestPath](http://www.openfst.org/twiki/bin/view/FST/ShortestPathDoc)
operation.

The following example applies LMBR decoding to the baseline lattices

    > lmbr.O2 --config=configs/CF.baseline.lmbr &> log/log.baseline.lmbr

The LMBR output hyppthesis file keeps the scale factor, word penalty, and sentence id at the start of the file;
the hypothesis follows the colon

    > cat output/exp.baseline.lmbr/HYPS/0.40_0.02.hyp
    0.4 0.02 1:1 3 9121 384 6 2756 7 3 4144 6 159312 42 1341 2
    0.4 0.02 2:1 3 1119 6 3 9121 1711 54 79 6 3 85 7 525 3 13907 17 3 628 5 2

LMBR can be optimised by tuning the grammar scale factor and word insertion penalty.
Once lattices are loaded into memory and n-grams are extracted (steps 1 - 5), rescoring is fast enough that
it is practical and efficient to perform a grid search over a range of 
parameter values (see config file).

Hypotheses are written to different files, with names based on parameter values (e.g. as
 `--writeonebest=output/exp.baseline.lmbr/HYPS/%%alpha%%_%%wps%%.hyp` ).
The best set of values can be selected based on BLEU score, after 
mapping each integer mapped output back to words, detokenizing, and scoring on against references.

LMBR relies on a unigram precision (p) and precision ratio (r) that are computed over a development set,
e.g. with verbose logs of a BLEU scorer such as NIST mteval1. 
The script `$HiFSTROOT/scripts/lmbr/compute-testset-precisions.pl` is included for this purpose.


If the option `--preprune=` is specified, the evidence space is pruned prior to computing posterior probabilities (i.e. pruning is done at threshold 7 in this example).  If this option is not defined, the full evidence space will be passed through.
