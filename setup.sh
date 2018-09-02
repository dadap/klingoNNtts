#!/bin/bash

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

if [ ! which git-lfs >/dev/null 2>&1 ]; then
    echo "git-lfs not detected. You will need git-lfs if you wish to retrieve"
    echo "pre-recorded speech samples stored in the tlhIngan-Hol-QIch-wab-tamey"
    echo "repository."

    echo "Type 'luq' and press enter if you want to proceed without git-lfs:"
    echo "You will need to supply your own speech samples if you do this."

    read resp

    if [ ! "$resp" = "luq" ]; then
        exit 1
    fi
fi

git submodule update --init --recursive
mkdir -p Ossian/corpus
ln -s ../../tlhIngan-Hol-QIch-wab-tamey Ossian/corpus/tlhInganHol

echo ""
echo "You will be asked for your HTK username and password. If you do not have"
echo "an HTK account, register at  http://htk.eng.cam.ac.uk/register.shtml"
echo "to create one. You can also enter bogus data for the HTK username and"
echo "password, but you will not be able to train models if you do so."
echo ""

read -p "HTK username: " htk_user
read -p "HTK password: " -s htk_pass
cd Ossian
./scripts/setup_tools.sh "$htk_user" "$htk_pass"
