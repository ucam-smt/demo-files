Rule Extraction                {#rulextract}
=================

The following consists of an outline of the ruleXtract tutorial.
Comments welcome. As per Rory's suggestions, some parts of the
tutorial target an advanced user with a hadoop cluster already
set up, other parts target a beginner without cluster setup or
hadoop knowledge.

\section Preliminaries

This tutorial is available at http://ucam-smt.github.io/tutorial/ .
You can also clone the tutorial code and generate the html as follows,
provided you have doxygen 1.8+ and latex installed:

    git clone https://github.com/ucam-smt/demo-files.git
    cd demo-files/Docs.dox
    doxygen

The html code will be generated in the `demo-files/Docs.dox/html` directory
and you can open the `demo-files/Docs.dox/html/index.html` with a
browser.

Requirements for building/running the rule extraction code:
  + 64-bit linux
  + [sbt](http://www.scala-sbt.org/)
  + java 1.7+

To get the code, use the following command:

    git clone https://github.com/ucam-smt/ucam-smt.git

The rule extraction code will be in the `ucam-smt/java/ruleXtract`
directory. The variable `$RULEXTRACT` designates this directory
from now on.

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

**Note**: a user already having access to a Hadoop cluster
may wish to skip this section.

We give instructions on how to set up a single
node Hadoop cluster. Specifically, we follow instructions
for the pseudo-distributed single node setup
from http://hadoop.apache.org/docs/r1.2.1/single_node_setup.html .
More information is available at http://hadoop.apache.org and
in the book "Hadoop, The Definitive Guide" by Tom White.

First, choose a working directory, for example `/home/mary/sandbox`, then
run the following commands:

    cd /home/mary/sandbox
    $RULEXTRACT/scripts/hadoopClusterSetup.bash

This should install the cluster. We now
detail the steps in the `hadoopClusterSetup.bash` script. You can also
have a look at the commands and comments inside the script for more info.
  + The java version is checked. If java 1.7+ is not installed, then
  a recent version of jdk is downloaded in the current directory, specifically
  jdk1.8.0_05 .
  + A recent version of hadoop is downloaded, specifically version 1.2.1 .
  + The configuration files in the hadoop directory are modified to allow
  pseudo-distributed mode and point to the correct `JAVA_HOME` .
  + Passwordless and passphraseless ssh is set. This is to make sure
  that the command `ssh localhost` works without any password or passphrase
  prompt.
  + The Hadoop Distributed File System (HDFS) is formatted.
  + Hadoop deamons are started. When this is done, you should
  be able to check the status of HDFS and MapReduce with a browser
  at the localhost:50070 and localhost:50030 respective addresses.
  + The HDFS `ls` command is tested.
  + The directory for your username is created (for example `/user/mary`)
  is created. Is is better to store your HDFS data in that directory rather
  than the root directory or the `/tmp` directory.
  + The cluster is shut down to avoid having java processes lying around.
  You will need to restart the cluster to run MapReduce jobs with the following
  command:

	`hadoop-1.2.1/bin/start-all.sh`


Note that this hadoop cluster installation is for tutorial purposes.
If you have a multi-core machine and enough memory (say 16G-32G), then
this cluster may be sufficient for extracting relatively large grammars.
However, a proper installation will use several nodes and a different
username for the Hadoop administrator.

In the remainder of this tutorial, the `$HADOOP_ROOT` variable
designates the Hadoop installation directory, for example
`/home/mary/sandbox/hadoop-1.2.1` .

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
