Introduction {#intro} 
=====================

This tutorial presents various tools and techniques developed in
the [Statistical Machine Translation](http://divf.eng.cam.ac.uk/smt) group at
the [Cambridge University Engineering Department](http://eng.cam.ac.uk).

The tutorial is intended to serve as a guide for the use of the tools, but our research publications contain the
best descriptions of the algorithms and modelling techniques described here.
The most relevant publications for this tutorial are listed below (\ref Refs).  In
particular, this tutorial is based on the Russian-English SMT system
developed for the WMT 2013 evaluation - we suggest reading the system description [\ref Pino2013] before starting on the tutorial.

Our complete publications can be found at <http://divf.eng.cam.ac.uk/smt/Main/SmtPapers>.

HiFST grew out of the Ph.D. thesis work of Gonzalo Iglesias.  

Contributors to this release are:  
- Graeme Blackwood
- Bill Byrne
- Adria de Gispert
- Federico Flego
- Gonzalo Iglesias
- Juan Pino
- Rory Waite
- Tong Xiao

with thanks to Cyril Allauzen and Michael Riley.

\section intro_features Features Included in this Release

- HiFST -- Hierarchical phrase-based statistical machine translation system based on \ref OpenFst
- Direct production of translation lattices as Weighted Finite State Automata
- Efficient WFSA rescoring procedures
- \ref OpenFst wrappers for direct inclusion of \ref KenLM and ARPA language models as WFSAs
- Lattice Minimum Bayes Risk decoding
- Lattice Minimum Error Rate training
- Tutorial for Hiero translation using Recursive Transition Networks and Pushdown Transducers
- Client/Server mode
- Shallow-N translation grammars
- Source-sentence `chopping' procedures
- WFSA true-casing
- Multi-dimensional parameter search for MERT 
- ...


\section Refs Relevant papers

\subsection Refs_decoding HiFST, HiPDT and Hierarchical Phrase-Based Decoding

\anchor deGispert2010 [deGispert2010]
*Hierarchical phrase-based translation with weighted finite state transducers and Shallow-N grammars*. <br>
A. de Gispert, G. Iglesias, G. Blackwood, E. R. Banga, and W. Byrne. Computational Linguistics, 36(3). 2010. <br>
<http://aclweb.org/anthology/J/J10/J10-3008.pdf>

\anchor Allauzen2014 [Allauzen2014]
*Pushdown automata in statistical machine translation*. <br>
C. Allauzen, W. Byrne, A. de Gispert, G. Iglesias, and M. Riley. Computational Linguistics. 2014. <br> <http://www.aclweb.org/anthology/J/J14/J14-3008.pdf>


\anchor Iglesias2009a [Iglesias2009a]
*Hierarchical phrase-based translation with weighted finite state transducers.*<br>
G. Iglesias, A. de Gispert, E. R. Banga, and W. Byrne. Proceedings of HLT. 2009.<br>
<http://aclweb.org/anthology//N/N09/N09-1049.pdf> <br>
<http://mi.eng.cam.ac.uk/~wjb31/ppubs/naaclhlt2009presentation.pdf>

\anchor Iglesias2011 [Iglesias2011]
*Hierarchical Phrase-based Translation Representations*. <br>
G. Iglesias, C. Allauzen, W. Byrne, A. de Gispert, M. Riley. Proceedings of EMNLP. 2011. <br>
<http://aclweb.org/anthology/D/D11/D11-1127.pdf>

\anchor Iglesias2009b [Iglesias2009b]
*Rule filtering by pattern for efficient hierarchical translation*.<br>
G. Iglesias, A. de Gispert, E. R. Banga, and W. Byrne. Proceedings of EACL. 2009. <br>
<http://aclweb.org/anthology/E/E09/E09-1044.pdf> <br>

\anchor Chiang2007 [Chiang2007]
*Hierarchical phrase-based translation*.<br>
Computational Linguistics. 2007 <br>
<http://aclweb.org/anthology/J07-2003.pdf>

\subsection Refs_systems CUED SMT System Descriptions

\anchor Pino2013 [Pino2013]
*The University of Cambridge Russian-English System at WMT13*. <br> J. Pino, A. Waite, T. Xiao, A. de Gispert, F. Flego, and W. Byrne.
Proceedings of the Eighth Workshop on Statistical Machine Translation. 2013. <br>
<http://aclweb.org/anthology//W/W13/W13-2225.pdf>

\subsection Refs_fsts OpenFST and Related Modelling Techniques

\anchor OpenFst [OpenFst]
The OpenFST Toolkit <http://www.openfst.org/>

\anchor Roark2011 [Roark2011]
*Lexicographic semirings for exact automata encoding of sequence models.* <br> B. Roark, R. Sproat, and I. Shafran. Proceedings of ACL-HLT. 2011. <br>
<http://aclweb.org/anthology/P/P11/P11-2001.pdf>

\subsection Refs_lmbr Lattice Minimum Bayes Risk Decoding using WFSAs

\anchor BlackwoodPhD [BlackwoodPhD]
*Lattice rescoring methods for statistical machine translation*.<br> G. Blackwood.  Ph.D. Thesis. Cambridge University Engineering Department and Clare College. 2010. <br>
<http://mi.eng.cam.ac.uk/~gwb24/publications/phd.thesis.pdf>

\anchor Blackwood2010 [Blackwood2010]
*Efficient path counting transducers for minimum Bayes-risk decoding of statistical machine translation lattices*.<br>
G. Blackwood, A. de Gispert, W. Byrne.  Proceedings of ACL Short Papers. 2010. <br>
<http://aclweb.org/anthology//P/P10/P10-2006.pdf>

\anchor Allauzen2010 [Allauzen2010]
*Expected Sequence Similarity Maximization*. <br> C. Allauzen, S. Kumar, W. Macherey, M. Mohri, M Riley.
  Proceedings of HLT-NAACL, 2010.  <br>
<http://aclweb.org/anthology//N/N10/N10-1139.pdf>

\subsection lmert_refs Mert

\anchor Macherey2008 [Macherey2008]
*Lattice-based Minimum Error Rate Training for Statistical Machine Translation*. <br>
W. Macherey, F. Och, I. Thayer, J. Uszkoreit.  Proceedings of EMNLP, 2008. <br>
<http://aclweb.org/anthology/D/D08/D08-1076.pdf>

\anchor Waite2015 [Waite2015]
*The Geometry of Statistical Machine Translation.*<br>
A Waite and W. Byrne. Proceedings of HLT. 2015. to appear<br>

\anchor Waite2014 [Waite2014]
*The Geometry of Statistical Machine Translation.* <br> A. Waite.  Ph.D. Thesis. Cambridge University Engineering Department and Girton College. 2014. <br>

\anchor Fukuda2004 [Fukuda2004]
*From the zonotope construction to the Minkowski addition of convex polytopes.* <br>
K Fukuda. Journal of Symbolic Computation, 38(4) <br>

\anchor Weibel2010 [Weibel2010]
*Implementation and parallelization of a reverse-search algorithm for Minkowski sums.* <br>
C Weibel. Proceedings of ALENEX 2010<br>
<http://epubs.siam.org/doi/pdf/10.1137/1.9781611972900.4>

\anchor Waite2012 [Waite2012]
*Lattice-based minimum error rate training using weighted finite-state transducers with tropical polynomial weights.*
<br> A. Waite, G. Blackwood, and W. Byrne. Proceedings of FSMNLP, 2012.<br>
<http://aclweb.org/anthology-new/W/W12/W12-6219.pdf>

\subsection rulextract_refs HiFST Rule Extraction

\anchor Pino2012 [Pino2012]
*Simple and Efficient Model Filtering in Statistical Machine Translation*. <br>
J. Pino, A. Waite, W. Byrne. Proceedings of PBML, 2012. <br>
<http://ufal.mff.cuni.cz/pbml/98/art-pino-waite-byrne.pdf>

\subsection othertools Language Modelling Toolkits
\anchor SRILM [SRILM]
SRI Language Model Toolkit<br>
<http://www.speech.sri.com/projects/srilm/>

\anchor KenLM [KenLM]
The KenLM Toolkit<br>
<http://kheafield.com/code/kenlm/>

