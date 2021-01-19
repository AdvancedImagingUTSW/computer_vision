module add cuda101/toolkit/10.1.243
module add python/3.6.4-anaconda
conda env list

conda create -n decon_env pycudadecon anaconda
# failed, as expected.  

# Add channels...
conda config --add channels conda-forge
conda config --add channels talley
conda create -n decon_env pycudadecon

source activate decon_env

conda list llspylibs
# Gives answer v 0.2.0, cu10.0.

<<COMMENT
Ran into an import error with numpy.

ImportError: 

IMPORTANT: PLEASE READ THIS FOR ADVICE ON HOW TO SOLVE THIS ISSUE!

Importing the numpy C-extensions failed. This error can happen for
many reasons, often due to issues with your setup or how NumPy was
installed.

We have compiled some common reasons and troubleshooting tips at:

    https://numpy.org/devdocs/user/troubleshooting-importerror.html

Please note and check the following:

  * The Python version is: Python3.7 from "/home2/kdean/.conda/envs/decon_env/bin/python"
  * The NumPy version is: "1.19.4"

and make sure that they are the versions you expect.
Please carefully study the documentation linked above for further help.

Original error was: libcblas.so.3: cannot open shared object file: No such file or directory

Removed numpy, and reinstalled it.  Works fine now.

Tifffile also works now.

COMMENT
# Deleted everything

conda create -n decon_env -c talley llspylibs tifffile numpy pytest python=3.7

# Cloned pycudadecon into ~/Desktop/Github/external/
git clone https://github.com/tlambert03/pycudadecon.git

# FUCKING CONDA FORGE
# Removed talley and conda-forge from ~/.condarc
conda create -n decon_env python=3.7 numpy tifffile
conda install -c talley llspylibs