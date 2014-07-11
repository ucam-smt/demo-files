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

The tutorial files and sources for this tutorial will be
in the `demo-files` directory. The variable `$DEMO`
designates this directory from now on. As an optional
step, if you wish to regenerate the HTML code for this
tutorial, make sure you have doxygen (1.8+
for markdown support) and
latex (for formulas) installed and run the following commands:

    cd $DEMO/Docs.dox
    doxygen

For this tutorial, it is assumed that rule extraction commands
are run from the `$DEMO` directory.

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

This should install the cluster in the `/home/$USER/hadoopcluster/hadoop-1.2.1`
directory. In the remainder of this tutorial, the `$HADOOP_ROOT`
variable designates the Hadoop installation directory. We now
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

      $HADOOP_ROOT/bin/start-all.sh

Once you are done with this tutorial, you can shut down the Hadoop
cluster with this command:

      $HADOOP_ROOT/bin/stop-all.sh

When running rule extraction commands, if you see a similar looking
log message:

      14/07/09 16:56:55 INFO ipc.Client: Retrying connect to server: localhost/127.0.0.1:9000. Already tried 0 time(s); retry policy is RetryUpToMaximumCountWithFixedSleep(maxRetries=10, sleepTime=1 SECONDS)

this means that the Hadoop cluster is not running and needs to be started.

Note that this Hadoop cluster installation is for tutorial purposes.
If you have a multi-core machine and enough memory (say 16G-32G), then
this cluster may be sufficient for extracting relatively large grammars.
However, a proper installation will use several nodes and a different
username for the Hadoop administrator.

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
  are run from the `$DEMO` directory. Please change to that
  directory:

      cd $DEMO

  All commands look like:

       $HADOOP_ROOT/bin/hadoop jar $RULEXTRACTJAR class args

  where `class` is a particular java class with a main method and
  `args` are the command line arguments. We use [JCommander](http://jcommander.org/)
  for command line argument parsing. You can therefore put all arguments
  in a configuration file `config` and use the syntax `@config` to replace
  the command line arguments (see the [@-syntax](http://jcommander.org/#Syntax)).

  Create a directory to store logs:

         mkdir -p logs

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
  to your home directory on HDFS, that is `/user/$USER`.
  Once the command is completed, you will find the training data at the following
  location on HDFS:

      /user/$USER/RUEN-WMT13/training_data

  You can verify this by running the Hadoop ls command:

      $HADOOP_ROOT/bin/hadoop fs -ls RUEN-WMT13

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

  Once the extraction is complete, you will find the rules
  in the `/user/$USER/RUEN-WMT13/rules/` HDFS directory.
  In this directory, you should see the following files:

    + `_SUCCESS` : this file indicates that the job successfully completed.
    + `_logs` : this directory contains metatdata about the job that has been run.
    + `part-r-*` : these files are the output of the Hadoop job.

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

  Once the job is complete, you will find the source-to-target probabilities
  in the `/user/$USER/RUEN-WMT13/s2t` HDFS directory.

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

  Once the job is complete, you will find the target-to-source probabilities
  in the `/user/$USER/RUEN-WMT13/t2s` HDFS directory.

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

  Once this step is completed, there will be 10 output hfiles
  in the `/user/$USER/RUEN-WMT13/merge` HDFS directory. For backup purposes
  and in order to make the subsequent retrieval step faster, it
  is advised to copy these hfiles to local disk as follows:

      mkdir -p hfile
      $HADOOP_ROOT/bin/hadoop fs -copyToLocal RUEN-WMT13/merge/*.hfile hfile/

\section rulextract_retrieval Grammar Filtering

  \subsection lex_model Lexical Models Download

  Lexical models are available as a separate download
  as they take some space. Run these commands:

      wget http://mi.eng.cam.ac.uk/~jmp84/share/align_giza.tar.gz
      tar -xvf align_giza.tar.gz

  \subsection lex_prob_server Lexical Probability Servers

  A preliminary step prior to grammar filtering is to launch lexical
  probability servers. These servers load IBM Model 1 probabilities
  for various provenances and for source-to-target and
  target-to-source directions. These probabilities have
  been obtained by the GIZA++ toolkit. For convenience, for this
  tutorial, we provide pretrained models. The source-to-target
  and target-to-source servers are launched as follows:

      export HADOOP_HEAPSIZE=30000
      export HADOOP_OPTS="-XX:+UseConcMarkSweepGC -verbose:gc -server -Xms30000M"
      $HADOOP_ROOT/bin/hadoop \
          jar $RULEXTRACTJAR \
          uk.ac.cam.eng.extraction.hadoop.features.lexical.TTableServer \
          @configs/CF.rulextract.lexserver \
          --ttable_direction=s2t \
          --ttable_language_pair=en2ru
      $HADOOP_ROOT/bin/hadoop \
          jar $RULEXTRACTJAR \
          uk.ac.cam.eng.extraction.hadoop.features.lexical.TTableServer \
          @configs/CF.rulextract.lexserver \
          --ttable_direction=t2s \
          --ttable_language_pair=ru2en

  Both servers should be launched in a separate terminal and without
  trailing ampersand to the commands. Once the servers are ready, a message
  similar to `"TTable server ready on port: 4949"` will be printed out.

  You can see the following options in the `configs/CF.rulextract.lexserver`
  configuration file:

    + `--ttable_s2t_server_port` : the port for the source-to-target server.
    + `--ttable_s2t_host` : the host for the source-to-target server.
    + `--ttable_t2s_server_port` : the port for the target-to-source server.
    + `--ttable_t2s_host` : the host for the target-to-source server.
    + `--ttable_server_template` : indicates a templated path to the lexical model
    where the templates `$GENRE` and `$DIRECTION` are replaced by their actual
	value.
    + `--provenance` : comma-separated provenances. This is used to search
    for the lexical models in the template.

  \subsection hadoop_local_conf Hadoop Local Configuration

  We have mentioned that retrieval is faster from local disk than
  from HDFS. In order to run Hadoop commands locally, we need
  to use a local configuration. This can be done by modifying
  the Hadoop configuration file that was prepared when setting
  up the Hadoop cluster:

      cp -r $HADOOP_ROOT/conf configs/hadoopLocalConf
      cat $HADOOP_ROOT/conf/mapred-site.xml | \
          $RULEXTRACT/scripts/makeHadoopLocalConfig.pl \
          > configs/hadoopLocalConf/mapred-site.xml
      cat $HADOOP_ROOT/conf/hdfs-site.xml | \
          $RULEXTRACT/scripts/makeHadoopLocalConfig.pl \
          > configs/hadoopLocalConf/hdfs-site.xml
      cat $HADOOP_ROOT/conf/core-site.xml | \
          $RULEXTRACT/scripts/makeHadoopLocalConfig.pl \
          > configs/hadoopLocalConf/core-site.xml

  \subsection retrieval Grammar Filtering

  Once the lexical probability servers are up, the Hadoop local
  configuration has been prepared and the lexical
  models have been downloaded, one can proceed to
  actual grammar filtering. This is done via the following
  command:

      $HADOOP_ROOT/bin/hadoop \
          --config configs/hadoopLocalConf \
          jar $RULEXTRACTJAR \
          uk.ac.cam.eng.rule.retrieval.RuleRetriever \
          @configs/CF.rulextract.retrieval \
          >& logs/log.retrieval

  You can see the following options in the `configs/CF.rulextract.retrieval`
  configuration file:

    + `--max_source_phrase` : the maximum source phrase length for a phrase-based rule.
    This option is used to control how source patterns are generated from the
	test file. The value for this option should be at most the value
	chosen when extracting rules. Otherwise, no rules will be found for certain
	patterns.
    + `--max_source_elements` : the maximum number of source elements (terminal
    or nonterminal) for a hiero rule.
    + `--max_terminal_length` : the maximum number of consecutive source terminals
    for a hiero rule.
    + `--max_nonterminal_length` : the maximum number of terminals covered by a
    source nonterminal.
    + `--hr_max_height` : the maximum number of terminals covered by the entire
    source side of a rule. The value for this option should be at most the value
    chosen for the `--cykparser.hrmaxheight` option in the HiFST decoder, otherwise
    some rules will never be used in decoding.
    + `--mapreduce_features` : comma-separated list of mapreduce features. Note that
    for the value for this option, we have used the value from the extraction phase
    and added lexical features.
    + `--provenance` : comma-separated list of provenances.
    + `--features`: comma-separated list of features.
    + `--pass_through_rules` : file containing special translation rules
    that copy source words or source word sequences to the target.
    + `--filter_config` : file with additional filter options.
    + `--source_patterns` : list of source patterns to be used in order to
    generate source pattern instances.
    + `--ttable_s2t_server_port` : the port for the source-to-target server. The
    value for this option should be same as the one used to launch the servers.
    + `--ttable_s2t_host` : the host for the source-to-target server.
    + `--ttable_t2s_server_port` : the port for the target-to-source server.
    + `--ttable_t2s_host` : the host for the target-to-source server.
    + `--retrieval_threads` : the number of threads. The value for this option
    should be equal to the number of HFiles obtained in the merge step.
    + `--hfile` : the directory containing the HFiles.
    + `--test_file` : the test set to be translated.
    + `--rules` : the output file containing relevant rules for the test set.

  Once this step is completed, you should obtain a rule file
  at this location: `$DEMO/G/rules.RU.tune.idx.gz`

  \subsection grammar_conversion Grammar Formatting

  In order to obtain a shallow grammar ready to use by the HiFST
  decoder, a postprocessing step is needed. This can be
  achieved via the following command:

      zcat -f G/rules.RU.tune.idx.gz | \
          $RULEXTRACT/scripts/prepareShallow.pl | \
          $RULEXTRACT/scripts/shallow2hifst.pl | \
          $RULEXTRACT/scripts/sparse2nonsparse.pl 27 | \
          gzip > G/rules.shallow.vecfea.all.prov.gz

  The `G/rules.shallow.vecfea.all.prov.gz` should
  contain the same rules as the `G/rules.shallow.vecfea.all.gz`
  used for the HiFST decoding tutorial and additional provenance features.

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
