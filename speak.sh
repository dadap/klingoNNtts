#!/bin/sh

if [ $# -lt 1 ]; then
    echo "USAGE: $0 voice_name [output_file] [ < file_to_speak ]"
    exit 1
fi

SPEAKER=$1

if [ $# -lt 2 ]; then
    OUTPUT=""
else
    OUTPUT="$2"
fi

cd `dirname $0`

if [ -f pyenv/bin/activate ]; then
    . pyenv/bin/activate
elif [ -d pyenv/conda-meta ]; then
    conda activate ./pyenv
else
    echo "Python environment not configured! Run setup.sh."
    exit 1
fi

TMPWAVDIR=`mktemp -d`

count=0

while read -p "Enter text to speak, or an empty line to finish: " line; do
    if [ -z "$line" ]; then
        break
    fi

    if [ -n "$OUTPUT" ]; then
        outopt="-o $TMPWAVDIR/`basename $OUTPUT`.part$count.wav"
        count=$(( $count + 1 ))
    else
        outopt="-play"
    fi

    xifan=`echo $line | sed -e s/ch/c/g -e s/D/d/g -e s/gh/G/g -e s/H/h/g \
           -e s/I/i/g -e s/ng/f/g -e s/G/g/g -e s/q/k/g -e s/Q/q/g \
           -e s/S/s/g -e s/tlh/x/g -e s/\'/z/g`

    echo $xifan | Ossian/scripts/speak.py -l tlhInganHol -s $SPEAKER $outopt \
         naive_01_nn
done

if [ -n "$OUTPUT" ]; then
    sox `find $TMPWAVDIR -type f | sort -V` $OUTPUT
fi

rm -rf "$TMPWAVDIR"
