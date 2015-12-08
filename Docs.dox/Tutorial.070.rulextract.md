Rule Extraction                {#rulextract}
=================

The rule extractor is a Hadoop MapReduce tool written in Java and Scala. It is fast, flexible, and can handle large amounts of training data. 

\section rulextract_prerequisites Prerequisites

 + [A Hadoop 2 cluster](http://hadoop.apache.org/releases.html "Download Hadoop")
 + [Scala 2.11](http://www.scala-lang.org/download/)

We assume that the Hadoop commands, including yarn and hdfs, are in your command path. If you do not have access to a Hadoop cluster, then a [single node cluster](http://hadoop.apache.org/docs/r2.6.0/hadoop-project-dist/hadoop-common/SingleCluster.html) is fine for the small amount of data in this tutorial.

The jar located at $RULEXTRACTJAR is a "fat jar", which means that all the dependences of the rule extractor are also included. A fat jar simplifies submission to the Hadoop cluster because dependencies do not need to be specified at job submission.

\section rulextract_tutorial_overview Tutorial

Rule extraction is split into two stages:

**Extraction**: Rules are extracted from the entire training set, counted, and rule probabilities are computed. This stage uses MapReduce for fast aggregation of statistics. The output is the set of all rules for the language pair stored in a simple database based on the HFile format.

**Retrieval**: For a given test set of parallel sentences the HFile is queried for constituent rules. Many of the features are computed as this stage, including lexical features. The retrieval stage does not require a Hadoop MapReduce cluster to run.

\subsection rulextract_tutorial_extraction Extraction

The extraction stage of the pipeline is modelled as a typical MapReduce batch process. Datasets are transformed into new datasets by Hadoop jobs, as shown in the following diagram:

![Extraction Pipeline](rulextract.svg)

For the remainder of this tutorial, it is assumed that commands are run from the `$DEMO` directory. Please change to that directory and ensure a log directory exists:

    > cd $DEMO
    > mkdir -p logs

Let us simplify the execution of the Hadoop commands by setting an environment variable:

    > RULEXTRACT="yarn jar $RULEXTRACTJAR"

The first step of the extraction pipeline is to load the training data on HDFS:

     > $RULEXTRACT \
         uk.ac.cam.eng.extraction.hadoop.util.ExtractorDataLoader \
         --hdfsout=RUEN-WMT13/training_data \
	     @configs/CF.rulextract \
         >& logs/log.loaddata

The extraction pipeline is driven by the configuration file `configs/CF.rulextract`. The configuration file specifies the source side of the training data (`--source=train/ru.sample.gz`), the target side (`--target=train/en.sample.gz`), and the alignments in the Berkeley format (`--alignment=train/align.berkeley.sample.gz`). The ExtractorDataLoader reads in the training data, and writes it in HDFS as a sequence file specified by the `--hdfsout` argument. 

The ExtractorDataLoader also requires a provenance file to be specified (`--provenance_file=train/provenance.sample.gz`). Provenances specify subsets of the training data for which to compute separate translation and lexical models. These models are treated as extra features in the linear model used by the decoder. 

The next step is to run the extractor:

    > $RULEXTRACT \
        uk.ac.cam.eng.extraction.hadoop.extraction.ExtractorJob \
        --input=RUEN-WMT13/training_data \
        --output=RUEN-WMT13/rules \
        @configs/CF.rulextract \
        >& logs/log.extract

This command performs the first of transformations in the pipeline. It:

+ extracts rules from parallel sentences.
+ aggregate the rules, such that the resulting dataset has 1 row per unique rule.
+ counts the occurrences of the rule in the training data according to provenance.

The output of most of the tools in the pipeline is a sequence file, which is difficult to inspect. To help visualize the data stored in sequence files we supply a tool that converts the sequence file to a text representation. To inspect the output of the extractor execute the following command:

    > $RULEXTRACT \
        uk.ac.cam.eng.extraction.hadoop.util.SequenceFilePrint \
        RUEN-WMT13/rules/part-r-00000 2>/dev/null \
        | head

which prints the sequence file as tab-separated values:

    3 6_18_4        {0=1, 1=1}      {0-2 =1}
    3_4_6002_6 4_5_2725_8   {0=1, 1=1}      {2-2 1-1 3-3 0-0 =1}
    3_5_64_266 370  {0=1, 1=1}      {2-0 3-0 =1}
    3_5_266_123_10557_63306_3 4_370_123776_21235_4_3        {0=1, 1=1}      {2-1 5-2 5-3 4-3 3-2 6-4 0-0 =1}
    3_5_399_1231_1940_24_3385_28107_3 4_171_10863_3334_6_16288_4089_4       {0=2, 1=2}      {8-7 2-2 5-4 4-2 4-3 7-5 1-1 3-1 3-2 6-6 0-0 =2}
    3_5_458_V 9_3_1552_6_V  {0=1, 1=1}      {2-2 1-0 =1}
    3_5_V_5291_V1 V_21498_6_V1      {0=1, 1=1}      {3-1 =1}
    3_5_V_130_3 9_V_14_226_4        {0=1, 1=1}      {4-4 1-0 3-2 3-3 =1}
    3_5_V_133_V1 8_9_V_206_10_V1    {0=1, 1=1}      {1-1 3-3 0-0 =1}
    3_6_27_706_3140 8_48_36_1414_3  {0=1, 1=1}      {2-1 4-3 1-0 3-2 =1}

Note that you may see different results due to the partitioning of the data by MapReduce. The first field is the rule, with the source and target side separated by a space. The second field is the map of counts by provenance. In this example each rule has two provenances indexed by 0 and 1. The 0 indexed value is the count across the whole of the training data, which is called the global provenance. The 1 indexed value is the count across the common crawl corpus (cc), and because the rule only occurs in this corpus both counts are equal. In the third field we see a list of the alignments which yield this rule and their associated global counts. In this example all of the rules are yielded by a single alignment, and the counts are equal to the global provenance count. 

Once rules have been extracted, the next step is to compute the rule probabilities. Our approach is to use two jobs to compute the target given source (source2target) and source given target (target2source) probabilities. Here is a quick summary of how the source2target job computes the probabilities:

+ Hadoop sorts the rules lexicographically by the source side first, then the target side.
    + The sort order is defined by a custom comparator.
    + To ensure that all rules with the same source side are sent to the same partition, only the source side of the rule is hashed.
+ Once sorted, all the rules with the same source side will be contiguous in the sequence file.
+ The reducer loads all the rules with the same source side in memory.
+ The reducer then computes the probabilities for all rules with the same source side.

The target2source job uses the same approach, but the lexicographic sort order is reversed such that all the target sides are contiguous in the sorted data.

The rule probability jobs are run using the following commands:

    > $RULEXTRACT \
        uk.ac.cam.eng.extraction.hadoop.features.phrase.Source2TargetJob \
        --input=RUEN-WMT13/rules \
        --output=RUEN-WMT13/s2t \
        >& logs/log.s2t 

    > $RULEXTRACT \
        uk.ac.cam.eng.extraction.hadoop.features.phrase.Target2SourceJob \
        --input=RUEN-WMT13/rules \
        --output=RUEN-WMT13/t2s \
        >& logs/log.t2s

We now have rule counts, and two sets of rule probabilities. The last step is to:

+ Merge all the statistics.
+ Filter rules with low counts and probabilities.
+ Create the file based database (HFile).

We do this with the MergeJob. Before we can run this job we need to edit the configuration file to set the location of files necessary for filtering. These files are specified by the following command line options in `configs/CF.rulextract`:

+ `--allowed_patterns=file://$DEMO/configs/CF.rulextract.filter.allowedonly`
+ `--source_patterns=file://$DEMO/CF.rulextract.patterns`

These files are specified by a full URI because they need to be accessible by every worker machine in the Hadoop cluster. For this tutorial we assume that the workers have access to a networked file system. If this is not the case, then you must load these files onto HDFS and use the `hdfs://` protocol in the configuration. Because the `file://` protocol does not allow for relative paths, the full path needs to added manually. For example:

    > sed "s:\$DEMO:$DEMO:g" configs/CF.rulextract > configs/CF.rulextract.expanded

The merge job can then be run as:

    > $RULEXTRACT \
        uk.ac.cam.eng.extraction.hadoop.merge.MergeJob \
        -D mapred.reduce.tasks=4 \
        --input_features=RUEN-WMT13/s2t,RUEN-WMT13/t2s \
        --input_rules=RUEN-WMT13/rules \
        --output=RUEN-WMT13/merge \
        @configs/CF.rulextract.expanded  \
        >& logs/log.merge

The one unusual option here is ` -D mapred.reduce.tasks=4`. This option instructs Hadoop to use only 4 reducers when creating the HFile. The output directory `RUEN-WMT13/merge` will then contain the data partitioned into 4 files.

It is useful to be able to fine tune `mapred.reduce.task` because the retriever queries each file in a separate thread. For the fastest retrieval times, the number of reducers should be set to be the same as number of threads as used in the retriever. Note that querying the HFile with a different number of threads does not change the results of the query. The query will just be slower.

The HFile is a binary format, which can be viewed with the HFile print tool:

          > $RULEXTRACT \
              uk.ac.cam.eng.extraction.hadoop.util.HFilePrint \
              RUEN-WMT13/merge/part-r-00000.hfile 2>/dev/null \
         	  | head

which yields

    3 4     RuleData [provCounts={0=8272, 1=8272}, alignments={0-0 =8272}, features={SOURCE2TARGET_PROBABILITY={0=-0.08468153736026644}, TARGET2SOURCE_PROBABILITY={0=-0.03958331665033461}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-0.08468153736026644}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-0.03958331665033461}}]
    3 8     RuleData [provCounts={0=287, 1=287}, alignments={0-0 =287}, features={SOURCE2TARGET_PROBABILITY={0=-3.4458309183488556}, TARGET2SOURCE_PROBABILITY={0=-1.7490483511350052}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-3.4458309183488556}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-1.7490483511350052}}]
    7 7_3   RuleData [provCounts={0=18, 1=18}, alignments={0-0 =8, 0-0 0-1 =9, 0-1 =1}, features={SOURCE2TARGET_PROBABILITY={0=-3.6535400876686275}, TARGET2SOURCE_PROBABILITY={0=-1.7346010553881064}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-3.6535400876686275}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-1.7346010553881064}}]
    7 17_11 RuleData [provCounts={0=10, 1=10}, alignments={0-0 =10}, features={SOURCE2TARGET_PROBABILITY={0=-4.241326752570746}, TARGET2SOURCE_PROBABILITY={0=-0.262364264467491}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-4.241326752570746}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-0.262364264467491}}]
    7 6     RuleData [provCounts={0=14, 1=14}, alignments={0-0 =14}, features={SOURCE2TARGET_PROBABILITY={0=-3.9048545159495336}, TARGET2SOURCE_PROBABILITY={0=-3.5326432677956565}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-3.9048545159495336}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-3.5326432677956565}}]
    7 9_3   RuleData [provCounts={0=11, 1=11}, alignments={0-0 =2, 0-0 0-1 =7, 0-1 =2}, features={SOURCE2TARGET_PROBABILITY={0=-4.146016572766421}, TARGET2SOURCE_PROBABILITY={0=-5.082533033275838}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-4.146016572766421}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-5.082533033275838}}]
    7 17    RuleData [provCounts={0=195, 1=195}, alignments={0-0 =195}, features={SOURCE2TARGET_PROBABILITY={0=-1.2709122870010454}, TARGET2SOURCE_PROBABILITY={0=-0.535142931416697}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-1.2709122870010454}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-0.535142931416697}}]
    7 7     RuleData [provCounts={0=53, 1=53}, alignments={0-0 =53}, features={SOURCE2TARGET_PROBABILITY={0=-2.5736199320126705}, TARGET2SOURCE_PROBABILITY={0=-2.741448481504058}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-2.5736199320126705}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-2.741448481504058}}]
    7 9_11  RuleData [provCounts={0=10, 1=10}, alignments={0-0 =1, 0-0 0-1 =9}, features={SOURCE2TARGET_PROBABILITY={0=-4.241326752570746}, TARGET2SOURCE_PROBABILITY={0=-1.9459101490553135}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-4.241326752570746}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-1.9459101490553135}}]
    7 17_3  RuleData [provCounts={0=67, 1=67}, alignments={0-0 =67}, features={SOURCE2TARGET_PROBABILITY={0=-2.3392192261738263}, TARGET2SOURCE_PROBABILITY={0=-0.5993284253422904}, PROVENANCE_SOURCE2TARGET_PROBABILITY={1=-2.3392192261738263}, PROVENANCE_TARGET2SOURCE_PROBABILITY={1=-0.5993284253422904}}]

In practise the HFile is queried by the retriever tool, but it can be useful for debugging to be see the raw output. Finally we need to copy the merge directory to local disk. Execute the following:

    > hdfs dfs -copyToLocal RUEN-WMT13/merge hfile

The Hadoop cluster is no longer needed, and can be shut down.

\subsection rulextract_tutorial_retrieval Retrieval

The HFile produced by the extraction stage contains all the rules extracted from the entire training data. In the retrieval stage the HFile is queried to produce a subset of the rules that can be applied to a test set. The retrieval tool also computes many of the features, including the lexical features, used in the decoder's linear model.

Lexical features require IBM Model 1 probabilities in the [GIZA](http://www.statmt.org/moses/giza/GIZA++.html) format. Lexical models are available as a separate download as they take a fair amount of disk space. To get these models run the following commands:

      > wget http://mi.eng.cam.ac.uk/~jmp84/share/giza_ibm_model1_filtered.tar.gz
      > tar -xvf giza_ibm_model1_filtered.tar.gz

These lexical models were filtered with the source vocabulary and target vocabulary of the test set for this tutorial to obtain a reasonable size for these models (the source vocabulary is easily obtained from the test set, the target vocabulary is obtained by taking target words from relevant translation rules for that test set).
If you wish, you can also download the [full models](http://mi.eng.cam.ac.uk/~jmp84/share/giza_ibm_model1_filtered.tar.gz)  but you will require a machine with about 30G RAM to load the data. 

The retrieval tool assumes that the lexical models are stored in a directory structure that can be split by provenance and direction. This structure is reflected in the configuration option `--ttable_server_template=giza_ibm_model1_filtered/genres/$GENRE/align/$DIRECTION/$DIRECTION.mode1.final.gz`. The variables `$GENRE` and `$DIRECTION` are used internally by the retriever to formulate the correct path to a model. For example, to get the source-to-target direction for the cc provenance the retriever sets `GENRE=cc` and `DIRECTION=en2ru` to locate:

    giza_ibm_model1_filtered/genres/cc/align/en2ru/en2ru.mode1.final.gz

Here is a quick summary of what the retriever does:

+ Generate all the possible source sides of a rule that can be found in a source sentence.
+ Partition the sets of source sides into queries for each file contained in the HFile directory.
+ Sort the queries.
+ Execute the queries and return rule counts, probabilities, and alignments for each rule found in the HFile.
+ Filter the rules for a second time.
+ Compute additional features, such as the lexical features.
+ Generate OOV, deletion rules, and pass-through rules based on the query results.
+ Write the results as shallow grammar.

Let us now run the retriever. Because retrieval also performs filtering, we need to use the `CF.rulextract.expanded` configuration from the previous section. Run the following Scala script:

    > $HiFSTROOT/java/ruleXtract/scripts/retrieve.scala \
        --s2t_language_pair en2ru --t2s_language_pair ru2en \
        --test_file=RU/RU.tune.idx \
        --rules=G/rules.RU.tune.idx.gz \
        --vocab=RU.tune.idx.vocab \
        @configs/CF.rulextract.expanded \
        >& logs/log.retrieval

The `s2t_language_pair` and `t2s_language_pair` options are used to set the `$DIRECTION` variable when locating lexical models. The `--test_file` option is the input file to translate and the output is stored in `--rules`. The output is stored as a gzipped shallow grammar, and can be used as input to HiFST:

    > /home/blue7/aaw35/tools/demo-files$ zcat G/rules.RU.tune.idx.gz | head
       V 542 2143 2.036882 0.980829 -1 -1 0 0 0 0 -1 0.841104 0.500422 2.036882 4.700000 4.700000 4.700000 0.980829 7 7 7 0.873349 0.652270 0.811145 40.001968 0.518248 0.367899 0.452543 40.001968
       V 435 7_3 2.197225 4.624973 -2 -1 0 0 -1 0 0 5.103256 5.981430 2.197225 4.700000 4.700000 4.700000 4.624973 7 7 7 7.014742 7.818437 5.184339 40.695116 6.225953 6.485531 6.219496 41.864230
       V 109 106 1.312186 1.189584 -1 -1 0 0 0 0 -1 1.206707 1.617768 1.312186 4.700000 4.700000 4.700000 1.189584 7 7 7 1.722831 1.505299 0.770817 40.001968 2.897182 0.356538 0.494034 40.001968
       V 298 12 2.302585 5.918894 -1 -1 0 0 -1 0 0 5.881671 8.218089 2.302585 4.700000 4.700000 4.700000 5.918894 7 7 7 6.500572 10.274702 7.688218 40.001968 7.903815 8.429022 8.320468 40.001968
       V 99 17_426 3.433987 0.693147 -2 -1 0 0 -1 0 0 1.033376 4.712400 3.433987 4.700000 4.700000 4.700000 0.693147 7 7 7 0.988207 0.782317 1.029978 1.290824 4.763535 5.242606 4.932181 45.396855
       V 79 40_83_13_27_180_19 3.433987 0.693147 -6 -1 0 0 -1 0 0 3.828080 24.055434 3.433987 4.700000 4.700000 4.700000 0.693147 7 7 7 3.752430 3.816584 3.814278 41.793728 26.486789 30.225935 26.563699 244.170694
       V 931 821_11 2.995732 1.945910 -2 -1 0 0 -1 0 0 1.060779 5.414462 2.995732 4.700000 4.700000 4.700000 1.945910 7 7 7 1.034481 0.940884 1.005978 40.695116 5.487767 5.069144 5.481220 48.615538
       V 454 21_499 3.401197 2.079442 -2 -1 0 0 -1 0 0 7.166555 10.007927 3.401197 4.700000 4.700000 4.700000 2.079442 7 7 7 6.709149 40.695116 9.531266 40.695116 10.229790 44.330405 12.247832 81.390231
       V 79 13_27_180 3.433987 0.693147 -3 -1 0 0 -1 0 0 3.172935 10.576585 3.433987 4.700000 4.700000 4.700000 0.693147 7 7 7 3.095097 3.152567 3.148776 41.100581 11.037732 14.379323 11.622925 122.085347
       V 735 7_603 2.772589 0 -2 -1 0 0 -1 0 0 1.801323 4.825997 2.772589 4.700000 4.700000 4.700000 0 7 7 7 1.909558 1.684512 1.756053 1.390172 5.103973 4.726153 4.772959 41.388263

If the optional `--vocab` value is set then the retriever will write out the target side vocabulary for each sentence on separate lines. [KenLM](https://kheafield.com/code/kenlm/) can use files in this format to filter large language models. 

\subsection rulextract_pipeline_lexserve Lexical Servers

As we have seen in the previous section, the lexical models can be very large. So large that they do not fit in memory of a single machine.  To deal with this problem the retriever uses a client-server model. The lexical models are stored in two servers, one for each direction, and the retriever requests probabilities from the servers as rules are read from the HFile. The Scala script in the previous section starts the two servers, waits for them to load the lexical models, and then starts the retriever.

Starting the lexical servers separately is only necessary if the lexical models are very large. In most cases the Scala script is the recommended approach. For the sole purpose of demonstrating the lexical servers in action, we now quickly retrieve the rules for individual sentences. Although the retriever was designed for batch processing, we can still achieve respectable query speeds that are close to real time by preloading the lexical models. First we need to start the servers:

    > java -Xmx5G -server \
       -classpath $RULEXTRACTJAR \
       uk.ac.cam.eng.extraction.hadoop.features.lexical.TTableServer \
	   @configs/CF.rulextract \
       --ttable_direction=s2t \
	   --ttable_language_pair=en2ru \
	   >& logs/log.s2t_server

and

    > java -Xmx5G -server \
       -classpath $RULEXTRACTJAR \
       uk.ac.cam.eng.extraction.hadoop.features.lexical.TTableServer \
	   @configs/CF.rulextract \
       --ttable_direction=t2s \
	   --ttable_language_pair=ru2en \
	   >& logs/log.t2s_server

Inspect the logs and wait until the lexical servers report they are ready. Once the models are loaded this message will appear in the logs:

    TTable server ready on port: ...

Let us now create an input file of a single sentence. For this example let us use sentence 2 because it is a long sentence.

    > head -n2 RU/RU.tune.idx | tail -n1 > 2.idx

Now we run the retriever for this single sentence, using the time command to see how long it takes:

    > time java \
       -classpath $RULEXTRACTJAR \
       uk.ac.cam.eng.rule.retrieval.RuleRetriever \
        --test_file=2.idx \
        --rules=2.shallow.gz \
        --vocab=2.vocab \
        @configs/CF.rulextract.expanded \
        >& logs/log.2_retrieval

and we can see the output that the grammar was generated in around 1.5 seconds:

    real    0m1.644s
    user    0m6.816s
    sys     0m0.324s

A respectable result considering that the pipeline is designed for batch processing.

\section rulextract_filtering Filtering

Most grammars will yield rules that are seen very infrequently in the training data. These rules cause the decoder search space to expand with very little benefit. To speed up decoding the low frequency rules are filtered out when generating grammars.

The rule extraction pipeline allows for fine-grained control of how rules are filtered. Filtering is performed twice, once during extraction, and once during retrieval. The reason for performing filtering twice is to enable experiments that determine the correct level of filtering. A more generous threshold can be applied at extraction, and then tightened at retrieval time.

Filtering is controlled by command line options, and two files:

+ A list of allowed rule patterns (`--allowed_patterns`).
+ A list of allowed source side patterns, with extra filtering criteria (`--source_patterns`).

The allowed rule patterns take the following form:

    V1_W_V-W_V_W_V1

The `W` symbol denotes any terminal symbol, and the `V` and `V1` symbols denote non-terminals. Any rules that do not fit these patterns are filtered from the final grammar.

Lines in the source patterns file have the following format:

    V_W_V1 2 10

+ The first field is an acceptable source side pattern, and the symbols have the same meaning as the allowed rules patterns.
+ The second field is the minimum number of times a rule with this source pattern must occur to be accepted into the final grammar.
+ The third field is the maximum number of rules that share the same source side that can be in the final grammar. If more than the maximum number of rules are found, then only the rules with the highest frequency are chosen.

We cover the rest of the filtering command line options in the next section.


\section rulextract_configuration_overview Configuration 

In the following table we list all possible command line options used in rule extraction. All options can be used either on the command line or specified in a configuration file. Configuration files are specified on the command line with the `@` symbol. Some tools share options and many tools specify `--input` and `--output` options, which we omit from the table. The tools also print help messages with a description of the required options.

The Source2TargetJob and Target2SourceJob tools only require `--input` and `--output` options and have been omitted from this table.

Note that the Scala script used for retrieval starts both lexical servers and then the retriever. Its command line options are a union of the lexical server and retriever options listed here.

<table>
	<tr> <th>Option</th> <th>Description</th> <th>ExtractorJob</th> <th>MergeJob</th><th>Lexical Server</th><th>Retrieval</th>    </tr>
	<tr>
		<td>remove_monotonic_repeats</td>
		<td>Clips counts. For example, given a monotonically aligned phrase pair <a b c, d e f>, the hiero rule <a X, d X> can be extracted from <a b, d e> and from <a b c, d e f>, but the occurrence count is clipped to 1.</td>
		<td > ✔ </td>
		<td>  </td>
		<td>  </td>
		<td>  </td>
	</tr>
	<tr>
		<td>max_source_phrase</td>
		<td>The maximum source phrase length for a phrase-based rule.</td>
		<td > ✔ </td>
		<td>  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>max_source_elements</td>
		<td> The maximum number of source elements (terminal or nonterminal)</td>
		<td > ✔ </td>
		<td>  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>max_terminal_length</td>
		<td> The maximum number of consecutive source terminals for a hiero rule.</td>
		<td > ✔ </td>
		<td>  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>max_nonterminal_span</td>
		<td> The maximum number of terminals covered by a source nonterminal.</td>
		<td > ✔ </td>
		<td>  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>provenance</td>
		<td> Comma-separated list of provenances.</td>
		<td > ✔ </td>
		<td>  </td>
		<td> ✔</td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>allowed_patterns</td>
		<td> The location of the allowed patterns file. It must be specified as a URI.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>source_patterns</td>
		<td> The location of the source patterns file. It must be specified as a URI.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>min_source2target_phrase</td>
		<td> Minimum source-to-target probability for filtering phrase-based rules.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>min_target2source_phrase</td>
		<td> Minimum target-to-source probability for filtering phrase-based rules.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>min_source2target_rule</td>
		<td> Minimum source-to-target probability for filtering hierarchical rules.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>min_target2source_rule</td>
		<td> Minimum target-to-source probability for filtering hierarchical rules.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>provenance_union</td>
		<td> Some rules may have a low global probability that falls below the filtering threshold, but high enough in a particular provenance to pass the threshold. The provenance union option allows these rules to pass through into the final grammar.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>input_features</td>
		<td> A comma separated list of the output of the Source2TargetJob and Target2SourceJob.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td>  </td>
	</tr>
	<tr>
		<td>input_rules</td>
		<td> The output of the extractor job.</td>
		<td > </td>
		<td> ✔  </td>
		<td>  </td>
		<td> </td>
	</tr>
	<tr>
		<td>ttable_s2t_server_port</td>
		<td> Source-to-target lexical server port.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>ttable_t2s_server_port</td>
		<td>Target-to-source lexical server port.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>ttable_s2t_host</td>
		<td>Source-to-target lexical server hostname.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> ✔ </td>
	</tr>			
	<tr>
		<td>ttable_t2s_host</td>
		<td>Target-to-source lexical server hostname.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> ✔ </td>
	</tr>
	<tr>
		<td>ttable_server_template</td>
		<td>Template string indicating the directory structure of the Giza lexical models. The template string can include $GENRE and $DIRECTION variables.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> </td>
	</tr>
	<tr>	
		<td>ttable_language_pair</td>
		<td>String to substitute in the $DIRECTION variable.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> </td>
	</tr>
	<tr>	
	<td>ttable_direction</td>
		<td>The direction of the ttable server. Valid values are "s2t" and "t2s".</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> </td>
	</tr>
	<tr>		
		<td>min_lex_prob</td>
		<td>Minimum probability for a Model 1 entry. Entries with lower probability are discarded. Used for reducing the memory consumed by a lexical server.</td>
		<td > </td>
		<td>  </td>
		<td> ✔</td>
		<td> </td>
	</tr>
	<tr>		
		<td>hr_max_height</td>
		<td>Maximum number of source terminals covered by the left-hand-side non-terminal in a hierarchical rule.</td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>	
		<td>features</td>
		<td>Comma separated list of features to include in the final grammar.</td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>pass_through_rules</td>
		<td>File containing pass-through rules.</td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>retrieval_threads</td>
		<td>The number of threads used to query the HFile. </td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>hfile</td>
		<td>Directory containing the HFile. </td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>test_file</td>
		<td>File containing the sentences to be translated. </td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>rules</td>
		<td>Gzipped output file containing the shallow grammar. </td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>
	<tr>
		<td>vocab</td>
		<td>File containing target side vocabulary for KENLM filtering. </td>
		<td > </td>
		<td>  </td>
		<td> </td>
		<td> ✔</td>
	</tr>		
</table>

