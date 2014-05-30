Rule Extraction                {#rulextract}
=================

The following consists of an outline of the ruleXtract tutorial.
Comments welcome. As per Rory's suggestions, some parts of the
tutorial target an advanced user with a hadoop cluster already
set up, other parts target a beginner without cluster setup or
hadoop knowledge.

\section Getting Started

General section for both kinds of users
with instructions on how to download
and compile the software. For compilation,
distinction may be made between building
a runnable jar or a normal jar.

\section Description of Files

Pretty much like what's done in the
main tutorial. Simply describe the format
for the source text, target text, word alignment and
extraction and retrieval cli/config.

\section Hadoop Cluster Setup

This section gives instruction
on how to set up a 1-node hadoop cluster
for the tutorial. The advanced user with
a hadoop cluster already installed is
advised to skip this section.

\section For the Impatient

ruleXtract provides two commands, one for
extraction and one for retrieval. This section
walks the advanced user very quickly through
a description of the input data (source text,
target text, word alignment) and the two
main commands.

\section With More Details

Similar to the previous section, this section
is divided in two subsections.
The first subsection concerns extraction.
Each step in extraction is run separately rather
than with one single command. Data loading,
extraction, source-to-target, target-to-source and
merging are run separately and command line options
and config file properties are explained in detail.
The same applies for retrieval: lex prob server/client,
retrieval, special rules (oov, dr, glue, etc.) explained
in detail. Possibly conversions from shallow grammars to
hiero grammars also explained.

\section Development

Instructions on how to modify the software.
Instructions for generating and Eclipse or
IntelliJ IDEA project.
Instructions on how to add a feature, either
a mapreduce or a local feature.

\section References

List of relevant papers. Can also be added
with all the HiFST papers.
