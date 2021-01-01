# Modules loaded
module load cuda11/blas/11.1.0
module load cuda11/fft/11.1.0
module load cuda11/toolkit/11.1.0
module load python/3.6.4-anaconda

# Going to start from scratch.  Specify python 3.7, and install default packages for Linux.
conda create -n cellpose python=3.7 anaconda
source activate cellpose

pip install cellpose
python -m cellpose

<<COMMENT 
Still getting the error Traceback (most recent call last):
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/runpy.py", line 193, in _run_module_as_main
    "__main__", mod_spec)
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/runpy.py", line 85, in _run_code
    exec(code, run_globals)
  File "/home2/kdean/Desktop/GitHub/external/cellpose/cellpose/__main__.py", line 4, in <module>
    from natsort import natsorted
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/natsort/__init__.py", line 3, in <module>
    from natsort.natsort import (
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/natsort/natsort.py", line 688, in <module>
    os_sort_key = os_sort_keygen()
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/natsort/natsort.py", line 656, in os_sort_keygen
    loc = natsort.compat.locale.get_icu_locale()
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/natsort/compat/locale.py", line 35, in get_icu_locale
    return icu.Locale(".".join(getlocale()))
AttributeError: module 'icu' has no attribute 'Locale'
COMMENT

# if I look into natsort, this is only called if icu is installed.  
conda remove -n cellpose icu

# Still didn't work.  Ended up commenting out all the crap that called on icu.
# Now, actually started...  
# New error.  Needed to install pip install cellpose[gui]
# Worked now...  
python -m cellpose

# GPU feature not enabled...  Now moving to that.
pip uninstall torch

# Checked pytorch version here: https://pytorch.org/get-started/locally/
conda install pytorch torchvision torchaudio cudatoolkit=11.0 -c pytorch

# GPU didn't work...
conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch

# Still didn't work...
nvidia-smi
# GPU Name Tesla P4

<<COMMENT2
(cellpose) [kdean@NucleusC012 cellpose]$ python
Python 3.7.9 (default, Aug 31 2020, 12:42:55) 
[GCC 7.3.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> torch.cuda.current_device()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/torch/cuda/__init__.py", line 366, in current_device
    _lazy_init()
  File "/home2/kdean/.conda/envs/cellpose/lib/python3.7/site-packages/torch/cuda/__init__.py", line 172, in _lazy_init
    torch._C._cuda_init()
RuntimeError: The NVIDIA driver on your system is too old (found version 10010). Please update your GPU driver by downloading and installing a new version from the URL: http://www.nvidia.com/Download/index.aspx Alternatively, go to: https://pytorch.org to install a PyTorch version that has been compiled with your version of the CUDA driver.
COMMENT2

# Had to restart things.  Still getting the same error.  I know I loaded the cuda11 toolkit, which is what I am supposed to have.
# Tested what version of CUDA I have...
nvcc --version

<<COMMENT3
(cellpose) [kdean@NucleusC012 cellpose]$ nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2020 NVIDIA Corporation
Built on Tue_Sep_15_19:10:02_PDT_2020
Cuda compilation tools, release 11.1, V11.1.74
Build cuda_11.1.TC455_06.29069683_0
COMMENT3

# Uninstalled torch...
pip uninstall torch

# Reinstalled with version 11, this time via pip
pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio===0.7.2 -f https://download.pytorch.org/whl/torch_stable.html

# Same problem.
module remove cuda11/toolkit/11.1.0
module add cuda101/toolkit/10.1.243

pip install torch==1.7.1+cu101 torchvision==0.8.2+cu101 torchaudio==0.7.2 -f https://download.pytorch.org/whl/torch_stable.html

# Now...  Finally gave me an answer
python
import torch
torch.cuda.current_device() # gives 0.
torch.cuda.device(0) #<torch.cuda.device object at 0x2aaab217edd0>
torch.cuda.get_device_name(0) #Tesla P4!!!

# Everything now seems to be working.
# 3D is very slow.  2D is nice.
# May be nice to merge the results from two different cell sizes
# 20 and 70


# Okay, launched it via command line.  Also seems to be working.
python -m cellpose --dir /home2/kdean/Desktop/temp/ \
--pretrained_model cyto --diameter 30. --save_png --do_3D --use_gpu

# default used the CPU.  Took ~4 minutes to process a 335.9 MB stack.