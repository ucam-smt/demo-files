
.. _setup-label:

Installation
=============

Installing dependencies
------------------------

SGNMT depends on the following libraries:

* `OpenFST <http://openfst.org/>`_ for reading and writing FSTs (e.g. translation lattices) (>=1.5.4)
* Optional: `Blocks <http://blocks.readthedocs.io/en/latest/>`_ for neural machine translation support based on Theano (>=0.1)
* Optional: `srilm-swig <https://github.com/desilinguist/swig-srilm>`_ for reading ARPA language model files
* Optional: `NPLM <http://nlg.isi.edu/software/nplm/>`_ for using feed-forward neural language models (>=0.3)


Installing OpenFST
**********************

We recommend to install `OpenFST 1.5.4 <http://openfst.org/twiki/bin/view/FST/FstDownload>`_. Make
sure to enable the Python support when compiling OpenFST::

    $ ./configure --enable-far --enable-python
    $ make
    $ make install

SGNMT requires OpenFST 1.5.4 because it is based on the extended Python API added in this version. For more information
see the documentation for the `OpenFST Python extension <http://www.openfst.org/twiki/bin/view/FST/PythonExtension>`_.

Newer OpenFST versions might not work since the Python API is under constant change.

If you wish to use SGNMT in combination with the hierachical phrase-pased SMT system `HiFST <http://ucam-smt.github.io/>`_,
you can directly use the OpenFST installation under *externals/* in the HiFST installation directory. This will make
it possible to create translation lattices with tropicalsparsetuple arcs with SGNMT to keep predictor scores separated 
(see *fst* output format).


Installing Blocks
**********************

Follow the `instructions <http://blocks.readthedocs.io/en/latest/setup.html>`_ in 
the blocks documentation to install the blocks framework and all its dependencies.

.. note:: 

      It might be necessary to install the HDF5 development files before installing blocks, e.g. with::

         $ sudo apt-get install libhdf5-dev 

.. tip::
    
      Make sure that all dependencies of blocks are updated. On systems where you don't have root access,
      use the pip options ``--user`` and ``--force-reinstall`` to install updated packages locally.

      `Anaconda <https://www.continuum.io/>`_ is another good option for
      local installations as it already sets up all packages Theano and Blocks depend on correctly. You still need
      to install Blocks with the `pip command <http://blocks.readthedocs.io/en/latest/setup.html>`_ using
      Anaconda's pip.


Installing SRILM
************************

First, install the version 1.7.1 of the `SRI language model toolkit <http://www.speech.sri.com/projects/srilm/>`_ if 
you don't already have an installation. 

.. note:: 

        According to the `documentation <https://github.com/desilinguist/swig-srilm>`_, swig-srilm requires that SRILM 
        is compiled as position independent code using ``MAKE_PIC=yes``::

          $ make World MAKE_PIC=yes

Then, checkout the srilm-swig project::

    $ git clone https://github.com/desilinguist/swig-srilm.git

Modify the Makefile as explained in the `installation instructions <https://github.com/desilinguist/swig-srilm>`_. For Ubuntu, the head of the make file should look like this::

    SRILM_LIBS=/path/to/srilm/lib/i686-m64
    SRILM_INC=/path/to/srilm/include
    PYTHON_INC=/usr/include/python2.7

Build the Python module::

    $ make python


Installing NPLM
************************

Download NPLM from the `project homepage <http://nlg.isi.edu/software/nplm/>`_ and install it. You can also
use the `UCAM NPLM fork <https://github.com/ucam-smt/nplm>`_ from Gonzalo Iglesias for threadsafety and efficiency.
If you are using nplm 0.3 there might be a bug in the Python module that prevents the nplm predictor from reading model files.
Try to replace *nplm.py* in the *python/* directory of your NPLM installation with `this file <http:///ucam-smt.io/sgnmt/html/_static/nplm.py>`_.

Setting up SGNMT
------------------

Update your environment variables to reflect the locations of OpenFST, SRILM, and NPLM. On Ubuntu, it might be necessary to
add */usr/local/lib* to your ``LD_LIBRARY_PATH`` (default location for OpenFST)::

    $ export LD_LIBRARY_PATH=/usr/local/lib/:/path/to/swig-srilm/:/path/to/nplm/src/python:$LD_LIBRARY_PATH
    $ export PYTHONPATH=/path/to/swig-srilm/:/path/to/nplm/python/:$PYTHONPATH

If OpenFST was not installed globally, you need to add it to your environment variables::

    $ export LD_LIBRARY_PATH=/path/to/openfst/lib:$LD_LIBRARY_PATH
    $ export PYTHONPATH=/path/to/openfst/lib/python2.7/site-packages:$PYTHONPATH

For setting up blocks, you'll also need to add ``on_unused_input='ignore'`` to your Theano flags as discussed `here <https://github.com/mila-udem/blocks-examples/issues/58>`_::

    $ export THEANO_FLAGS="on_unused_input='ignore'"

Clone the GIT repository and try to start ``decode.py`` and ``train.py``::

    $ git clone https://github.com/ucam-smt/sgnmt.git
    $ cd sgnmt
    $ python train.py --help
    $ python decode.py --help

If you see the help texts for both commands, you are ready for the :ref:`tutorial-label`. Otherwise, there is probably
something wrong with your Blocks or OpenFST installation. 
