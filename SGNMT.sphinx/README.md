Install the sphinx extensions::

    pip install sphinxcontrib-napoleon
    pip install sphinx_rtd_theme
    pip install sphinx-argparse

How to generate the docs::

    make clean
    sphinx-apidoc -f -o . ../../sgnmt/ ../../sgnmt/cam/sgnmt/blocks/machine_translation
    make html

Or if sphinx is installed locally

    make clean
    ~/.local/bin/sphinx-apidoc -f -o . ../../sgnmt/ ../../sgnmt/blocks/machine_translation
    make html

If it doesn't work, change the path to sphinx-build in the Makefile.