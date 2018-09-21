#!/bin/sh

set -e

if [ "$#" -lt "1" ]; then
    echo "USAGE: $0 SPEAKER_NAME [DESTINATION_FILE_NAME]"
    exit 1
fi

SPEAKER="$1"
DEST_FILE="$2"
OSS_DIR="`dirname $0`/Ossian"

if [ -z "$DEST_FILE" ]; then
    DEST_FILE="klingoNNtts-voice-model-$SPEAKER.tar.bz2"
fi

if [ -e "$DEST_FILE" ]; then
    echo "$DEST_FILE already exists. Consider renaming or deleting it, or"
    echo "choosing a different destination file name."
    exit 1
fi

echo "Creating archive: this may take a moment…"

tar -C $OSS_DIR -cjf "$DEST_FILE" \
    "train/tlhInganHol/speakers/$SPEAKER/naive_01_nn/questions_dnn.hed.cont" \
    "train/tlhInganHol/speakers/$SPEAKER/naive_01_nn/questions_dur.hed.cont" \
    "voices/tlhInganHol/$SPEAKER/naive_01_nn/processors" \
    "voices/tlhInganHol/$SPEAKER/naive_01_nn/voice.cfg"

if [ $? ]; then
    echo "Qapla'! Voice model successfully exported to $DEST_FILE."
else
    echo "Qagh! Failed to export voice model."
    rm -f "$DEST_FILE"
    exit 1
fi
