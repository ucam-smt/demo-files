
.. _setup-label:

Installation
===========================

We recommend installing SGNMT inside an Anaconda environment. This guide contains step-by-step
instructions to set up the SGNMT environment from scratch on an Ubuntu >=14.04 system, including 
installing Anaconda and various dependencies like TensorFlow, T2T, OpenFST, etc. 

First, `download the Anaconda installer <https://www.anaconda.com/>`_. We used Anaconda 2019.03
(Python 3.7) in this guide. Accept the license and choose the Anaconda installation direction. We refer 
to this directory as ``<ANACONDA>``.

Change to a new directory where you wish to install SGNMT. We refer to this directory as ``<SGNMT>``. The 
latest SGNMT version is available on github::

    $ git clone https://github.com/ucam-smt/sgnmt.git

Activate your base Anaconda environment::

   eval "$(<ANACONDA>/bin/conda shell.bash hook)"

And create a new environment for SGNMT::

   conda create -n sgnmt_env pip python=3.6

.. note:: 

      In this guide we use Python 3.6 because TensorFlow 1.13 is not compatible with
      Ubuntu 14.04 under more recent Python versions (more on this `here <https://github.com/tensorflow/tensorflow/issues/26826>`_). 
      If you don't need compatibility with Ubuntu 14.04 or you don't use TensorFlow, select a more recent Python version.


You can activate this new environment with::

   conda activate sgnmt_env

Install dependencies under the activated ``sgnmt_env`` environment::

   conda install numpy pyyaml scipy

Test SGNMT::

    python <SGNMT>/decode.py --help

We recommend to use an activation script ``<ACTIVATE.SH>`` to set up the SGNMT environment and some
of the environment variables for external libraries (see below). This is an example of an initial
``<ACTIVATE.SH>`` script::

    # Activate Anaconda environment
    eval "$(<ANACONDA>/bin/conda shell.bash hook)"
    conda activate sgnmt_env
    
    # SGNMT
    export SGNMT=<SGNMT>

End your current session and log in again with a clean shell. Then, test it with::

    source <ACTIVATE.SH>
    python $SGNMT/decode.py --help


Installing optional dependencies
----------------------------------

A minimal version of SGNMT runs with basic setup described above. However, some output formats
and predictors depend on external libraries:

* `Tensor2Tensor <https://github.com/tensorflow/tensor2tensor>`_ for a wide range of different sequence models in TensorFlow (>=1.7.0)
* `fairseq <https://github.com/pytorch/fairseq>`_ for a wide range of different sequence models in PyTorch (>=0.7.0)
* `KenLM <https://github.com/kpu/kenlm>`_ for reading ARPA language model files with KenLM backend (latest)
* `OpenFST <http://openfst.org/>`_ for reading and writing FSTs (e.g. translation lattices) (>=1.5.4)

To print out available external libraries, use::

    python $SGNMT/decode.py --run_diagnostics

Diagnostics are useful after installing optional dependencies to verify that the installation was successful.



Installing Tensor2Tensor
************************

`Tensor2Tensor <https://github.com/tensorflow/tensor2tensor>`_ is a TensorFlow-based library with support of various neural 
sequence models. SGNMT can access models trained with tensor2tensor via the *t2t* predictor. Follow the 
`tensor2tensor installation instructions <https://github.com/tensorflow/tensor2tensor#installation>`_ to install t2t and
TensorFlow. Make sure that you have activated your Anaconda environment::

  # Assumes tensorflow or tensorflow-gpu installed
  pip install tensor2tensor
  
  # Installs with tensorflow-gpu requirement
  pip install tensor2tensor[tensorflow_gpu]
  
  # Installs with tensorflow (cpu) requirement
  pip install tensor2tensor[tensorflow]

If you need both the GPU and the CPU versions we recommend using two separate Anaconda environments.
Note that SGNMT supports the ``--t2t_usr_dir`` argument to extend the registry of T2T to your custom directory.

.. note:: 

      The Tensor2Tensor code base is still under constant change, and SGNMT might or might not be compatible with the latest 
      version.

*Tested versions: Tensor2Tensor 1.7.0-1.13.4 TensorFlow 1.9-1.13.1*


Installing fairseq
************************

Follow the `installation instructions for PyTorch <https://pytorch.org/>`_ in your activated Anaconda environment. Then,
`install fairseq <https://github.com/pytorch/fairseq>`_, for example using ``pip``::

  pip install fairseq

For more information on how to use fairseq models in SGNMT, see :ref:`tutorial_pytorch-label`.

*Tested versions: PyTorch 1.1, fairseq 0.7.1*


Installing KenLM
************************

Follow the instructions on the `KenLM Github page <https://github.com/kpu/kenlm>`_ to install KenLM::

    pip install https://github.com/kpu/kenlm/archive/master.zip

*Tested versions: latest*


Installing OpenFST
**********************

SGNMT supports two variants to install the Python interface to OpenFST. The easier option is to install
the pre-compiled `openfst-python <https://pypi.org/project/openfst-python/>`_ package with pip::

    pip install openfst-python

Alternatively, OpenFST can be built from the sources without relying on a third-party package. The issue
at the time of writing is that the `official OpenFST release 1.7.2 <http://openfst.org/twiki/bin/view/FST/FstDownload>`_. 
does not support Python 3 out-of-the-box. For future OpenFST versions with Python 3 support, compile with::

    $ ./configure --enable-far --enable-python
    $ make
    $ make install

and add the following lines to ``<ACTIVATE.SH>``::

    export LD_LIBRARY_PATH=/path/to/openfst/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=/path/to/openfst/lib/python<VERSION>/site-packages:$PYTHONPATH

If you wish to use SGNMT in combination with the hierachical phrase-pased SMT system `HiFST <http://ucam-smt.github.io/>`_,
you can directly use the OpenFST installation under *externals/* in the HiFST installation directory. This will make
it possible to create translation lattices with tropicalsparsetuple arcs with SGNMT to keep predictor scores separated 
(see *fst* output format).

*Tested versions: OpenFST 1.5.4-1.7.2*


