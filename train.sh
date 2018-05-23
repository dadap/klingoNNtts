#!/bin/sh

set -ex

if [ $# -lt 2 ]; then 
    echo "Usage: $0 LANG SPEAKER [MODEL]"
    exit 1
fi

TTSLANG=$1
TTSSPEAKER=$2

if [ $# -gt 2 ]; then
    TTSMODEL=$3
else
    TTSMODEL=naive_01_nn
fi

cd `dirname $0`/Ossian

. ../pyenv/bin/activate

rm -rf ./train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL ./voices/$TTSLANG/$TTSSPEAKER/$TTSMODEL

python ./scripts/train.py -s $TTSSPEAKER -l $TTSLANG $TTSMODEL

export THEANO_FLAGS=""

for predictor in duration acoustic; do
    python tools/merlin/src/run_merlin.py train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor/config.cfg
    python scripts/util/store_merlin_model.py train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor/config.cfg voices/$TTSLANG/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor
done
