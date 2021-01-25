# https://github.com/imagej/pyimagej

module load python/3.6.4-anaconda
# conda create -n pyimagej -c conda-forge pyimagej openjdk=8
# Failed.  Couldn't find python 3.8?

#conda conda create -n pyimagej -c conda-forge pyimagej openjdk=8 python=3.7
# Also failed.  

conda create -n pyimagej python=3.8
source activate pyimagej
conda install -c conda-forge pyimagej openjdk=8
# https://anaconda.org/conda-forge/pyimagej

# Numpy failed. Uninstalled conda-forge version, reinstalled pip version.  
# Reinstalled pyimagej and openjdk via conda-forge channel.

# Can figure out the python path inside of python
python
import os
print("PYTHONPATH:", os.environ.get('PYTHONPATH'))
# PYTHONPATH: /cm/shared/apps/cnvkit/0.9.5/lib/python3.6/site-packages:
# /cm/shared/apps/python/3.6.4-anaconda/lib

print("PATH:", os.environ.get('PATH'))
#PATH: /home2/kdean/.conda/envs/pyimagej/bin:
# /cm/shared/apps/cnvkit/0.9.5/bin:
#/cm/shared/apps/python/3.6.4-anaconda/bin:
#/cm/shared/apps/slurm/16.05.8/sbin:
#/cm/shared/apps/slurm/16.05.8/bin:
#/usr/local/bin:/usr/bin:
#/opt/ibutils/bin:
#/sbin:
#/usr/sbin:
#/cm/local/apps/environment-modules/3.2.10/bin:
#/home2/kdean/gmic-scripts-install/

# Maybe try via PIP?
# Maven is working.

conda remove --name pyimagej --all
conda create -n pyimagej python=3.8
# Still broken.