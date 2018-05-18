#!/bin/sh

set -e

cd `dirname "$0"`

if ! [ -f pyenv/bin/activate ]; then
    virtualenv pyenv
fi

. pyenv/bin/activate

pip install -r requirements.txt | grep -v '^Requirement already satisfied:'
