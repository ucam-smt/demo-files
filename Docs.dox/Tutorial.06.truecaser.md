\page Truecasing
\section true_casing Fst-based True casing

HiFST includes a tool typically used for  true casing the output. It relies on two models: 

- A true-case integer-mapped language model in ARPA or KenLM format.
- A flower transducer that transduces uncased words to every true case alternative. 
  This model is loaded from a file with the following format per line, one for each uncased word:
     - uncased-case-word true-case-word1 prob1 true-case-word2 prob2 ...
     - This format is compatible with the unigram model for \ref SRILM [disambig](http://www.speech.sri.com/projects/srilm/manpages/disambig.1.html) tool (see `--map` option).

Words must be integer-mapped. A file with this model is available:

    > head  G/tc.unimap
    1 1 1.0
    2 2 1.0
    3 5943350 0.00002 3 0.86370 5943349 0.13628
    4 4 1.00000
    5 5 1.00000
    6 5942623 0.00452 5942624 0.00002 6 0.99546
    7 5943397 0.00000 5943398 0.01875 7 0.98121 5943399 0.00004
    8 5941239 0.00003 8 0.99494 5941238 0.00502
    9 5942238 0.06269 9 0.93729 5942239 0.00002
    10 5943348 0.00001 10 0.99498 5943347 0.00501

For example, under this model word 4 (comma ",") transduces to itself with probability 1.
The uncased word 3 ("the") has three upper-case alternatives: "the", "THE", and "The", with the following probabilities

     P(the | the) = 0.86
     P(THE | the) = 0.00002
     P(The | the) = 0.13628

To generate these probabilities, you just need counts of truecased words. You can extract these unigrams 
with \ref SRILM [ngram-count] (http://www.speech.sri.com/projects/srilm/manpages/ngram-count.1.html) tool,
and calculate the probability of each particular true-cased form given the aggregated number of lower-cased instances.


These models are provided to the recaser module via the following configuration options

    > cat configs/CF.recaser
    [recaser]
    lm.load=M/lm.tc.gz
    unimap.load=G/tc.unimap

The true casing procedure is very similar to that of \ref SRILM [disambig](http://www.speech.sri.com/projects/srilm/manpages/disambig.1.html) tool.
In our case this is accomplished with two subsequent compositions, followed by exact pruning. 
An acceptable performance vs speed/memory trade-off can be achieved e.g. with offline entropy pruning of the language model.

A range of input lattices can be true-cased in the following way with our fst-based disambig tool:

    > disambig.O2 configs/CF.recaser --recaser.input=output/exp.hiero.pdt/LATS/?.fst.gz --recaser.output=output/exp.recasing/LATS/?.fst.gz --range=1:2 -s lexstdarc

The result can be printed as so:

    > printstrings.O2 --range=1:2 --input=output/exp.recasing/LATS/?.fst.gz --semiring=lexstdarc --label-map=wmaps/wmt13.en.wmap 2>/dev/null
    <s> The Republican strategy of resistance to the renewal of Obama 's election </s>
    <s> The leaders of the Republican justified their policies need to deal with the spin on the elections . </s>

Note that both models need to be integer-mapped, hence the external target wordmap (--label-map) must also map true case words.

HiFST can include truecasing as subsequent step following decoding, prior to writing the output hypotheses. For instance:

    > hifst.O2 --config=configs/CF.hiero.pdt.recaser --target.store=output/exp.hiero.pdt/recased/hyps &> log/log.hiero.pdt.recase

    > farcompilestrings --entry_type=line output/exp.hiero.pdt/recased/hyps | farprintstrings --symbols=wmaps/wmt13.en.wmap
    <s> The Republican strategy of resistance to the renewal of Obama 's election </s>
    <s> The leaders of the Republican justified their policies need to deal with the spin on the elections . </s>

However, the output lattices are left in uncased form:

    > zcat output/exp.hiero.pdt/LATS/1.fst.gz | printstrings.O2 --semiring=lexstdarc --label-map=wmaps/wmt13.en.wmap -w 2>/dev/null
    <s> the republican strategy of resistance to the renewal of obama 's election </s> 		     55.2515,-11.6445



