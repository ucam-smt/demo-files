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

If you're not root or sudo, you can follow these
[instructions](http://www.scala-sbt.org/0.13/tutorial/Manual-Installation.html)

If you don't know how to install java, here's one way to install
java 7 on Ubuntu, as described
[here](http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html) (for java 8, see [here](http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html)):

    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
    sudo apt-get install oracle-java7-installer

If you're not root or sudo, simply download
JDK and update the `PATH` and `JAVA_HOME`
accordingly.

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
may wish to skip this section, after adding these dependencies
to the `HADOOP_CLASSPATH` : `jcommander-1.35`, `hbase-0.92.0` and
`guava-r09` .

**Note**: we use Hadoop 1 as opposed to Hadoop 2
(see [this discussion](http://hadoop.apache.org/docs/r2.3.0/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduce_Compatibility_Hadoop1_Hadoop2.html)).
We also use the more recent API of Hadoop, which means
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

This should install the cluster in the `$HOME/hadoopcluster/hadoop-1.2.1`
directory. In the remainder of this tutorial, the `$HADOOP_ROOT`
variable designates the Hadoop installation directory. We now
detail the steps in the `hadoopClusterSetup.bash` script. You can also
have a look at the commands and comments inside the script for more information.
  + The java version is checked. If java 1.7+ is not installed, then
  a recent version of jdk is downloaded in the current directory, specifically
  jdk1.8.0_05 .
  + A recent version of Hadoop is downloaded, specifically version 1.2.1 .
  + Libraries on which the code is dependent are downloaded.
  + The configuration files in the Hadoop directory are modified to allow
  pseudo-distributed mode and point to the correct `JAVA_HOME` . The
  `HADOOP_CLASSPATH` is also modified to point to libraries that the code
  depends on.
  + Passwordless and passphraseless ssh is set. This is to make sure
  that the command `ssh localhost` works without any password or passphrase
  prompt.
  + The Hadoop Distributed File System (HDFS) is formatted.
  + Hadoop deamons are started. When this is done, you should
  be able to check the status of HDFS and MapReduce with a browser
  at the `localhost:50070` and `localhost:50030` respective addresses.
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

this means that the Hadoop cluster is not running and needs to be (re)started.

Note that this Hadoop cluster installation is for tutorial purposes.
If you have a multi-core machine and enough memory (say 16G-32G), then
this cluster may be sufficient for extracting relatively large grammars.
However, a proper installation will use several nodes and a different
username for the Hadoop administrator.

After running the installation script, if you still run into
trouble while running the rule extraction commands, you may run
the following commands as a last resort (note that this
will delete all your HDFS data):

    $HADOOP_ROOT/bin/stop-all.sh
    rm -rf /tmp/hadoop*
    $HADOOP_ROOT/bin/hadoop namenode -format
	$HADOOP_ROOT/bin/start-all.sh

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
Rule retrieval is decomposed into the following steps:
 + launch lexical probability servers: lexical features
are computed with a client/server architecture rather than
with MapReduce because lexical models take a fair amount of memory.
 + rule retrieval: rules relevant to a test set are looked up
in the HFiles produced by the extraction phase.
 + grammar formatting: a grammar with a format suitable for the HiFST
decoder is produced.

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

  After running rule extraction commands that produce an output
  on HDFS, you can visualize the output using either the SequenceFile
  printer or the HFile printer provided. For example, after having
  run the extraction step (see below), you can see the extracted rules
  as follows:

      $HADOOP_ROOT/bin/hadoop \
          jar $RULEXTRACTJAR \
          uk.ac.cam.eng.extraction.hadoop.util.SequenceFilePrint \
          RUEN-WMT13/rules/part-r-00000

  This will print the first chunk of rules extracted.
  After the merging step, you can visualize rules, alignments and features
  as follows:

      $HADOOP_ROOT/bin/hadoop \
          jar $RULEXTRACTJAR \
          uk.ac.cam.eng.extraction.hadoop.util.HFilePrint \
          RUEN-WMT13/merge/part-r-00000.hfile

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

  **Note**: for this tutorial, we use a sample of the training data available
  for the Russian-English
  [translation task at WMT13](http://statmt.org/wmt13/translation-task.html).
  If you wish to test rule extraction with the entire data, modify
  `$DEMO/configs/CF.rulextract.load` with the following options:

    + `--source=train/ru.gz`
    + `--target=train/en.gz`
    + `--alignment=train/align.berkeley.gz`
    + `--provenance=train/provenance.gz`

  For the full data, we give indicative timing measurements obtained
  on our cluster of 12 machines with 16 cores and 47G RAM each:

    + extraction: 106m
    + s2t : 12m
    + t2s : 13m
    + merge : 41m
    + retrieval : 11m

  \subsection rulextract_extract Rule Extraction

  Once the training data has been loaded onto HDFS, rules can be extracted.
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
  This specifies the number of reducers at runtime. Unfortunately, the number
  of reducers is not determined automatically by the Hadoop framework. You
  can also specify the number of reducers in the `mapred-site.xml`
  Hadoop cluster configuration file with the `mapred.reduce.tasks`
  property.
  Because main classes
  all implement the `Tool` interface, you can specify generic options
  at the command line (see [this example](http://hadoopi.wordpress.com/2013/06/05/hadoop-implementing-the-tool-interface-for-mapreduce-driver/)
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

    + `--input_features` : comma separated list of output from feature computation
    + `--input_rules` : the extracted rules on HDFS
    + `--output` : merged output

  We need both rules and features as input because the merge job adds word alignment
  information into the output using the rules.
  Once this step is completed, there will be 10 output hfiles
  in the `/user/$USER/RUEN-WMT13/merge` HDFS directory. For backup purposes
  and in order to make the subsequent retrieval step faster,
  copy these hfiles to local disk as follows:

      mkdir -p hfile
      $HADOOP_ROOT/bin/hadoop fs -copyToLocal RUEN-WMT13/merge/*.hfile hfile/

  If you are using NFS, it's better to copy the hfiles to local disk, e.g.
  `/tmp` or `/scratch` .

\section rulextract_retrieval Grammar Filtering

  \subsection lex_model Lexical Models Download

  Lexical models are available as a separate download
  as they take a fair amount of disk space. Run these commands:

      wget http://mi.eng.cam.ac.uk/~jmp84/share/giza_ibm_model1.tar.gz
      tar -xvf giza_ibm_model1.tar.gz

  **Note**: the tarball size is 2.6G so you may want to take a break
  while it's being downloaded.

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
  configuration has been prepared, one can proceed to
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
    or nonterminal) for a hiero rule. Same remarks as for `--max_source_phrase`
    apply.
    + `--max_terminal_length` : the maximum number of consecutive source terminals
    for a hiero rule. Same remarks as for `--max_source_phrase` apply.
    + `--max_nonterminal_length` : the maximum number of terminals covered by a
    source nonterminal. Usually we set the value for this option to be equal
    to the one used in the extraction phase but it's possible to choose any
    value smaller that the value of `--hr_max_height` .
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
    + `--filter_config` : file with additional filter options. This configuration
    file determines what patterns are allowed, minimum source-to-target and target-to-source
    probabilities for phrase-based and hierarchical rules, etc. See the
    comments in `$DEMO/configs/CF.rulextract.filter` for details.
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
          gzip > G/rules.shallow.vecfea.sample.prov.gz

  The `G/rules.shallow.vecfea.sample.prov.gz` file should
  be ready to be used by the HiFST decoder with the
  `--grammar.load` option. If you've changed
  the `configs/CF.rulextract.load` configuration
  file to use the entire training data, then you should
  obtain a file with the same rules as in
  `G/rules.shallow.vecfea.all.gz` with the same
  first 11 features and additional provenance features.

\section Development

  \subsection ide IDE Development

In order to generate a project file for Eclipse,
please follow these [instructions](https://github.com/typesafehub/sbteclipse).
For IntelliJ IDEA, follow these [instructions](https://github.com/mpeltonen/sbt-idea).

  \subsection local_feature Adding a Local Feature

  We give instructions on how to add a local feature to rule extraction.
  In order to compute a local feature for a rule, we only need to consider
  that rule. For example, the number of target terminals in a rule is a
  local feature. Let's add that feature:

    + In the `uk.ac.cam.eng.rulebuilding.features` package, create
    a new class called `NumberTargetElements` . Its featureName
    field can be for example "number_target_elements".
    + This class should implement the `Feature` class from the same
    package.
    + Implement the required methods for that class. You can
    look at the WordInsertionPenalty class in the same package for an example.
    + In the constructor of the FeatureCreator class in the same package,
    add the following line:

        features.put("number_target_elements", new NumberTargetElements());

    + Modify the `--features` option to include `number_target_elements`
    in the comma-separated list of features. If you follow the tutorial
    commands, you can modify the `configs/CF.rulextract.retrieval` configuration
    file.

  If you get stuck, you can see what modifications are needed
  [here](https://github.com/ucam-smt/ucam-smt/commit/09f697d1e7e6f35e9e04c37e3f00b0c7780b6d67)

  \subsection mapreduce_feature Adding a MapReduce Feature

  We now give instructions on how to add a MapReduce feature.
  In order to compute a MapReduce feature, we need to consider
  all rules extracted from the training data rather than
  a single rule at a time. For example, let's add source-to-target
  and provenance source-to-target probabilities with add-one smoothing:

    + In the `uk.ac.cam.eng.extraction.hadoop.features.phrase` package, create
	a new class called `Source2TargetAddOneSmoothedJob` . This class
	is very similar to `Source2TargetJob` except that the mapper
	adds one to the rule counts.
    + Modify the `MapReduceFeature` class to add the new feature.
    + Follow the steps to add a local feature.
    + Change the `--mapreduce_feature` option to be the following:

        --mapreduce_features=source2target_probability,target2source_probability,provenance_source2target_probability,provenance_target2source_probability,source2target_addonesmoothed_probability,provenance_source2target_addonesmoothed_probability

    + For merging, change the `--input_features` option to be the following:

        --input_features=RUEN-WMT13/s2t,RUEN-WMT13/t2s,RUEN-WMT13/s2taddone

    + Since there is a new feature, you need to run a command analogous to
    the one run to obtain source-to-target probabilities
    + For retrieval, modify the `--mapreduce_features` and the `--features`
    options to be as follows:

        --mapreduce_features=source2target_probability,target2source_probability,provenance_source2target_probability,provenance_target2source_probability,source2target_addonesmoothed_probability,provenance_source2target_addonesmoothed_probability,source2target_lexical_probability,target2source_lexical_probability,provenance_source2target_lexical_probability,provenance_target2source_lexical_probability
        --features=source2target_probability,target2source_probability,word_insertion_penalty,rule_insertion_penalty,glue_rule,insert_scale,rule_count_1,rule_count_2,rule_count_greater_than_2,source2target_lexical_probability,target2source_lexical_probability,provenance_source2target_probability,provenance_target2source_probability,provenance_source2target_lexical_probability,provenance_target2source_lexical_probability,source2target_addonesmoothed_probability,provenance_source2target_addonesmoothed_probability

  The code modifications are [here](https://github.com/ucam-smt/ucam-smt/commit/7cba14a596f5e428ce69fe2620e411ecfe0e8d71).