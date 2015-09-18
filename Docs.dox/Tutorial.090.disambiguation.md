Non-functional WFST Disambiguation {#nfdisambiguation}
======================================================

The ucam-smt package contains a disambiguation algorithm
that supports [non-functional](http://www.openfst.org/twiki/bin/view/FST/FstGlossary#FunctionalDef) WFSTs, i.e. ambiguous WFSTs in which repeated translation hypotheses have different label sequences.
For a detailed description, please check [\ref Iglesias2015].
The gist of the disambiguation algorithm is as follows:

1. Map the topologically sorted WFST into an equivalent WFSA using weights that contain both the WFST weight and the output symbols. This requires a special  semiring.
2. Apply WFSA determinization under this semiring to ensure that only one unique path per input string survives.
3. Expand the result back to an WFST that preserves arc-level alignments.

The implementation of our disambiguation algorithm relies on the
\ref lmert_veclats_tst, which is already implemented
in the ucam-smt package. It allows to define zero-weighted sparse features
on this semiring, which we call _Topological Features_. These identify arcs/output labels in the original topologically sorted WFST. The expansion algorithm in step 3 also ensures that the topological features are placed correctly, so that a 1-1 mapping back to WFST is possible.

In one step of the previous tutorial on \ref bilm, HiFST generates affiliation lattices in output/bilmexp/AFILATS.STD/. In these lattices, each translation hypothesis has one or more affiliation sequences, i.e. these lattices are non-functional.

We can count the number of hypotheses of the first lattice as so:

     > zcat  output/bilmexp/AFILATS.STD/1.fst.gz | countstrings.${TGTBINMK}.bin --input=- --output=-
     2601

But the number of unique hypotheses is actually much smaller:

     > zcat  output/bilmexp/AFILATS.STD/1.fst.gz | fstproject --project_output | fstdeterminize | countstrings.${TGTBINMK}.bin --input=- --output=-
     98

This happens because there are repeated input sequences for each translation hypothesis:

     > printstrings.${TGTBINMK}.bin --input=output/bilmexp/AFILATS.STD/1.fst.gz  --print-input-output-labels -n 10 | grep "1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2"
     1 5 6 4 2 7 7 9 9 9 12 11 10 14         1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2       75.5229
     1 5 6 4 2 7 7 9 9 9 13 11 10 14         1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2       76.2495

We can disambiguate these lattices as so:

     > disambignffst.${TGTBINMK}.bin --range=1:10 --input=output/bilmexp/$it/AFILATS.STD/?.fst.gz --output=output/exp.lmert/$it/AFIDETLATS/?.fst.gz --nthreads=4 --determinize-output=yes

And for the first lattice, we now have the same number of unique hypotheses:

     > zcat  output/bilmexp/AFIDETLATS/1.fst.gz   | countstrings.${TGTBINMK}.bin --input=- --output=-
     98

And we now have only the best affiliation sequence per hypothesis:

     > printstrings.${TGTBINMK}.bin --input=output/bilmexp/AFIDETLATS/1.fst.gz  --print-input-output-labels -n 10 -w | grep "1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2"
     1 5 6 4 2 7 7 9 9 9 12 11 10 14         1 3 511 342 1480 866 11 3 3286 5 717 35351 9967 2       75.5229



