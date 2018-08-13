#!/bin/sh

set -ex

if [ $# -lt 1 ]; then
    echo "Usage: $0 SPEAKER [LANG [MODEL]]"
    exit 1
fi

TTSSPEAKER=$1

if [ $# -gt 1 ]; then
    TTSLANG=$2
else
    TTSLANG=tlhInganHol
fi

if [ $# -gt 2 ]; then
    TTSMODEL=$3
else
    TTSMODEL=naive_01_nn
fi

cd `dirname $0`/Ossian

# XXX one of the activate scripts doesn't work when activating within a script;
# require activation ahead of time for now.
# conda activate ../pyenv

rm -rf ./train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL ./voices/$TTSLANG/$TTSSPEAKER/$TTSMODEL

python ./scripts/train.py -s $TTSSPEAKER -l $TTSLANG $TTSMODEL

export THEANO_FLAGS="device=cuda,floatX=float32"
export MKL_THREADING_LAYER="GNU"

sed -i -e "s/^training_epochs  : .*$/training_epochs  : 100/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/duration_predictor/config.cfg

sed -i -e "s/^learning_rate    : .*$/learning_rate    : 0.0006/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/acoustic_predictor/config.cfg
sed -i -e "s/^training_epochs  : .*$/training_epochs  : 350/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/acoustic_predictor/config.cfg
sed -i -e "s/^warmup_epoch     : .*$/warmup_epoch     : 300/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/acoustic_predictor/config.cfg
#sed -i -e "s/^hidden_layer_size  : .*$/hidden_layer_size  : [2048, 2048, 2048, 2048, 2048, 2048]/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/acoustic_predictor/config.cfg
sed -i -e "s/^batch_size       : .*$/batch_size       : 2048/" train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/acoustic_predictor/config.cfg

for predictor in duration acoustic; do
    python tools/merlin/src/run_merlin.py train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor/config.cfg
    python scripts/util/store_merlin_model.py train/$TTSLANG/speakers/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor/config.cfg voices/$TTSLANG/$TTSSPEAKER/$TTSMODEL/processors/${predictor}_predictor
done
