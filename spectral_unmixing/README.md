# spectralUnmixing

Python 3.6-based software for measuring spectral crosstalk and performing linear unmixing.  

## How do I install it?

All software was written in Python 3.6, and only tested in a Linux environment.  We recommend that you do the same.

### Here's how to setup your machine for development:

1. Clone the *spectralUnmixing* repository via the UTSW GIT server.

2. Go to the *spectralUnmixing* directory and create a new Python virtual environment `conda env create -f spectralunmixing.yml`. 

3. Activate the created virtual environment by writing `conda activate spectralunmixing`

## How do I use it?

The genral workflows were designed initially in a Jupyter-Notebook, and can be found in the main folder.  This includes calculate-m-values.ipynb and unmix_data.py.  The dependent functions are in the unmix_functions directory.

