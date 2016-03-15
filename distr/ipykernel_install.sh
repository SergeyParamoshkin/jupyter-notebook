#!/bin/bash 

conda create -n py27 python=2.7 --quiet --yes
source activate py27 && conda install --quiet --yes notebook ipykernel
python -V 
ipython kernel install

conda create -n py35 python=3.5  --quiet --yes
source activate py35 && conda install --quiet --yes notebook ipykernel
python -V 
ipython kernel install
