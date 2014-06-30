Rule Extraction                {#rulextract}
=================

\section rulextract_start Getting started

Requirements for building/running the rule extraction code:
  + an Internet connection
  + preferably 64-bit linux
  + [sbt](http://www.scala-sbt.org/)
  + java 1.7+

If you don't know how to install sbt, here's one way to do it
on Ubuntu:

    wget http://dl.bintray.com/sbt/debian/sbt-0.13.5.deb
    sudo dpkg -i sbt-0.13.5.deb

If you don't know how to install java, here's one way to install
java 7 on Ubuntu, as described
[here](http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html) (for java 8, see [here](http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html)):

	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java7-installer

**Note**: the java version used to run your Hadoop cluster should be
greater or equal to the java version used to compile the code; otherwise
you may get an "Unsupported major.minor version" error.

To get the code, use the following command:

    git clone https://github.com/ucam-smt/ucam-smt.git

or:

    git clone git@github.com:ucam-smt/ucam-smt.git

The rule extraction code will be in the `ucam-smt/java/ruleXtract`
directory. The variable `$RULEXTRACT` designates this directory
from now on.

To build the rule extraction software, simply run the
following commands:

    cd $RULEXTRACT
    sbt package

You will obtain a jar file named `ruleXtract.jar`
located at `$RULEXTRACT/target/ruleXtract.jar` .
The variable `$RULEXTRACTJAR` designates this
jar from now on.

To get the tutorial files, run this command:

    git clone https://github.com/ucam-smt/demo-files.git

\section rulextract_cluster_setup Hadoop Cluster Setup

**Note**: a user already having access to a Hadoop cluster
may wish to skip this section.

**Note**: we use Hadoop 1 as opposed to Hadoop 2
(see [this discussion](http://hadoop.apache.org/docs/r2.3.0/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduce_Compatibility_Hadoop1_Hadoop2.html)).
We also used the more recent API of Hadoop, which means
that in general the import statements use the `org.apache.hadoop.mapreduce`
package instead of the `org.apache.hadoop.mapred` package.

We give instructions on how to set up a single
node Hadoop cluster. Specifically, we follow instructions
for the pseudo-distributed single node setup
from http://hadoop.apache.org/docs/r1.2.1/single_node_setup.html .
More information is available at http://hadoop.apache.org and
in the book "Hadoop, The Definitive Guide" by Tom White.

First, choose a working directory, for example `$HOME/hadoopcluster`, then
run the following commands:

    mkdir -p $HOME/hadoopcluster
    cd $HOME/hadoopcluster
    $RULEXTRACT/scripts/hadoopClusterSetup.bash

This should install the cluster. We now
detail the steps in the `hadoopClusterSetup.bash` script. You can also
have a look at the commands and comments inside the script for more information.
  + The java version is checked. If java 1.7+ is not installed, then
  a recent version of jdk is downloaded in the current directory, specifically
  jdk1.8.0_05 .
  + A recent version of hadoop is downloaded, specifically version 1.2.1 .
  + Libraries on which the code is dependent are downloaded.
  + The configuration files in the hadoop directory are modified to allow
  pseudo-distributed mode and point to the correct `JAVA_HOME` . The
  `HADOOP_CLASSPATH` is also modified to point to libraries that the code
  depends on.
  + Passwordless and passphraseless ssh is set. This is to make sure
  that the command `ssh localhost` works without any password or passphrase
  prompt.
  + The Hadoop Distributed File System (HDFS) is formatted.
  + Hadoop deamons are started. When this is done, you should
  be able to check the status of HDFS and MapReduce with a browser
  at the localhost:50070 and localhost:50030 respective addresses.
  + The HDFS `ls` command is tested.
  + The directory for your username (`/user/$USER`)
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
`/home/$USER/hadoopcluster/hadoop-1.2.1` .

\section rulextract_pipeline_overview Pipeline Overview

Grammar extraction is composed of two main steps: extraction
and retrieval.

Extraction consists in extracting all phrase-based and hierarchical
rules from word-aligned parallel text and computing model scores
for these rules. Extraction is itself
decomposed into the following steps:
 + training data loading: the training data, i.e. word aligned
parallel text, is loaded onto HDFS.
 + extraction: rules are simply extracted, no scores are computed
 + model score computation: scores are computed for the extracted
rules. Currently, source-to-target and target-to-source probabilities
are computed.
 + merging: the various outputs from the previous step (score computation)
are merged so that a rule can be associated to multiple scores.

Rule retrieval, or rule filtering, consists in obtaining
rules and scores that are only relevant to a given input test
set or a given input sentence to be translated.

The next section details the various steps for grammar extraction.

\section rulextract_grammar_extraction Grammar Extraction

  \subsection rulextract_commands Running Commands

  In the remainder of this tutorial, it is assumed that commands
  are run from the `demo-files` directory. All commands
  look like:

  	   $HADOOP_ROOT/bin/hadoop jar $RULEXTRACTJAR class args

  where `class` is a particular java class with a main method and
  `args` are the command line arguments. We use [JCommander](http://jcommander.org/)
  for command line argument parsing. You can therefore put all arguments
  in a configuration file `config` and use the syntax `@config` to replace
  the command line arguments (see the [@-syntax](http://jcommander.org/#Syntax)).

  Create a directory to store logs:

  		 mkdir logs

  \subsection rulextract_load_data Data Loading

  The first step in grammar extraction is to load the training data onto HDFS.
  This is done via the following command:

  	   $HADOOP_ROOT/bin/hadoop \
	       jar $RULEXTRACTJAR \
		   uk.ac.cam.eng.extraction.hadoop.util.ExtractorDataLoader \
		   @configs/CF.rulextract.load \
		   >& logs/log.loaddata

  You can see the following options in the `configs/CF.rulextract.load`
  configuration file:

    + `--source` : a gzipped text file with one source sentence per line.
    + `--target` : a gzipped text file with one target sentence per line.
    + `--alignment` : a gzipped text file with one sentence pair word alignment per line in
    Berkeley format.
    + `--provenance` : a gzipped text file with one set of space separated provenances for
    a sentence pair per line. In general, each sentence pair has the 'main' provenance, unless
    you want to exclude some sentence pairs from the general source-to-target and target-to-source
    computation.
    + `--hdfsout` : the location of the training data on HDFS.

  For `--hdfsout`, you can specify a relative or absolute path. The relative path is relative
  to your home directory on HDFS.

  \subsection rulextract_extract Rule Extraction

  Once the training data has been loaded to HDFS, rules can be extracted.
  This is done via the following command:

       $HADOOP_ROOT/bin/hadoop \
	       jar $RULEXTRACTJAR \
		   uk.ac.cam.eng.extraction.hadoop.extraction.ExtractorJob \
		   @configs/CF.rulextract.extract \
		   >& logs/log.extract

  You can see the following options in the `configs/CF.rulextract.extract`
  configuration file:

    + `--input` : the input training data on HDFS. This was the output from data loading.
    + `--output` : the extracted rules on HDFS. This is a directory.
    + `--remove_monotonic_repeats` : clips counts. For example, given a monotonically aligned
    phrase pair
    <a b c, d e f>, the hiero rule <a X, d X> can be extracted from <a b, d e> and from
    <a b c, d e f>, but the occurrence count is clipped to 1.
    + `--max_source_phrase` : the maximum source phrase length for a phrase-based rule.
    + `--max_source_elements` : the maximum number of source elements (terminal or nonterminal)
    for a hiero rule.
    + `--max_terminal_length` : the maximum number of consecutive source terminals for a hiero rule.
    + `--max_nonterminal_length` : the maximum number of terminals covered by a source nonterminal.
    + `--provenance` : comma-separated list of provenances.

  \subsection rulextract_s2t Source-to-target Probability

  The output of the previous job is the input to feature computation.
  We start by computing source-to-target rule probabilities for each
  provenance. This is done via the following command:

       $HADOOP_ROOT/bin/hadoop \
	       jar $RULEXTRACTJAR \
		   uk.ac.cam.eng.extraction.hadoop.features.phrase.Source2TargetJob \
		   -D mapred.reduce.tasks=16 \
		   @configs/CF.rulextract.s2t \
		   >& logs/log.s2t

  You can see the following options in the `configs/CF.rulextract.s2t`
  configuration file:

    + `--input` : the extracted rules on HDFS. This was the output from rule extraction.
    + `--output` : the source-to-target probabilities on HDFS.
    + `--provenance` : comma-separated list of provenances.
    + `--mapreduce_features` : comma-separated list of features. This is important
    to give the correct index to each feature.

  Note that the command line also has the option `-D mapred.reduce.tasks=16` .
  This specifies the number of reducers at runtime. Because main classes
  all implement the `Tool` interface, you can specify generic options
  in the command line (see [this example](http://hadoopi.wordpress.com/2013/06/05/hadoop-implementing-the-tool-interface-for-mapreduce-driver/)
  and the [API documentation](https://hadoop.apache.org/docs/r1.2.1/api/org/apache/hadoop/util/Tool.html) for more detail).

  \subsection rulextract_t2s Target-to-source Probability

  Computation of other features can be done simultaneously.
  Computing target-to-source probabilities for each provenance
  can be done as follows:

       $HADOOP_ROOT/bin/hadoop \
	       jar $RULEXTRACTJAR \
		   uk.ac.cam.eng.extraction.hadoop.features.phrase.Target2SourceJob \
		   -D mapred.reduce.tasks=16 \
		   @configs/CF.rulextract.t2s \
		   >& logs/log.t2s

  You can see the following options in the `configs/CF.rulextract.t2s`
  configuration file:

    + `--input` : the extracted rules on HDFS.
    + `--output` : the source-to-target probabilities on HDFS.
    + `--provenance` : comma-separated list of provenances.
    + `--mapreduce_features` : comma-separated list of features.

  \subsection rulextract_merge Feature Merging

  Once all features have been computed, rules and features
  are merged into a single output. This can be done via the
  following command:

       $HADOOP_ROOT/bin/hadoop \
	       jar $RULEXTRACTJAR \
		   uk.ac.cam.eng.extraction.hadoop.merge.MergeJob \
	   	   -D mapred.reduce.tasks=10 \
		   @configs/CF.rulextract.merge \
		   >& logs/log.merge

  You can see the following options in the `configs/CF.rulextract.merge`
  configuration file:

    + `--input` : comma separated list of output from feature computation
    + `--output` : merged output


\section rulextract_retrieval Grammar Filtering

The same applies for retrieval/filtering: lex prob server/client,
retrieval, special rules (oov, dr, glue, etc.) explained
in detail. Possibly conversions from shallow grammars to
hiero grammars also explained.

\section rulextract_impatient For the Impatient

ruleXtract provides two commands, one for
extraction and one for retrieval. This section
walks the advanced user very quickly through
a description of the input data (source text,
target text, word alignment) and the two
main commands.

\section Development

Instructions on how to modify the software.
Instructions for generating and Eclipse or
IntelliJ IDEA project.
Instructions on how to add a feature, either
a mapreduce or a local feature.

\section References

List of relevant papers. Can also be added
with all the HiFST papers.

\section rulextract_files Description of Files

Pretty much like what's done in the
main tutorial. Simply describe the format
for the source text, target text, word alignment and
extraction and retrieval cli/config.
