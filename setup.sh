#!/bin/sh

set -e

cd `dirname "$0"`

if [ -z "$CONDA_HOME" ]; then
    CONDA_HOME=~/miniconda2
fi

if [ ! -f $CONDA_HOME/etc/profile.d/conda.sh ]; then
    echo "Cannot find Anaconda: if it is already installed, set CONDA_HOME"
    echo "to the root of your Anaconda installation."

    echo "Type 'luq' and press enter if you want to proceed without Anaconda:"
    echo "GPU support will not be available if you do this."

    read resp

    if [ "$resp" = "luq" ]; then
        NOCONDA=1
    else
        exit 1
    fi
else
    NOCONDA=
fi

if [ "$NOCONDA" = "1" ]; then
    virtualenv pyenv
    . pyenv/bin/activate
else
    . $CONDA_HOME/etc/profile.d/conda.sh
    if ! [ -x pyenv/bin/python ]; then
        conda create -p ./pyenv python=2.7
    fi
    conda activate ./pyenv
fi

# Install numpy first to work around dependency resolution
pip install numpy
pip install -r requirements.txt

if [ "$NOCONDA" = "1" ]; then
    pip install theano
else
    conda install theano
fi
