#!/bin/sh

set -e

cd `dirname "$0"`

if [ -z "$CONDA_HOME" ]; then
    CONDA_HOME=~/miniconda2
fi

if [ ! -f $CONDA_HOME/etc/profile.d/conda.sh ]; then
    echo "Cannot find Anaconda: if it is already installed, set CONDA_HOME"
    echo "to the root of your Anaconda installation."
    exit 1
fi

. $CONDA_HOME/etc/profile.d/conda.sh

if ! [ -x pyenv/bin/python ]; then
    conda create -p ./pyenv python=2.7
fi

conda activate ./pyenv

# Install numpy first to work around dependency resolution
pip install numpy
pip install -r requirements.txt
conda install theano
