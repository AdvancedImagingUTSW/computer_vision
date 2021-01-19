#!/bin/bash

module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate napari-env

# Clear PyTorch Memory
python -c "import torch; torch.cuda.empty_cache(); print('Done Emptying Cache')"

# Launch Cellpose - Previous diameter was set to 30
python -m cellpose
