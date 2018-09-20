#!/bin/sh

set -e

if [ "$#" -lt "1" ]; then
    echo "USAGE: $0 MODEL_FILE"
    exit 1
fi

MODEL_FILE="$1"
OSS_DIR="`dirname $0`/Ossian"

FOUND=""

for file in `tar tf $MODEL_FILE`; do
    if echo "$file" | grep -v '/$' > /dev/null && [ -e "$OSS_DIR/$file" ]; then
        FOUND="    $OSS_DIR/$file\n$FOUND"
    fi
done

echo "Checking archive files…"

if [ -n "$FOUND" ]; then
    echo "The following files present in the model archive are already present:"
    echo
    echo "$FOUND"
    echo "Importing this model will overwrite these files."
    echo "Type (r)uch to proceed or (q)Il to cancel:"

    while read response; do
        case $response in
            r*) break ;;
            q*) exit 1 ;;
	    *) echo "Dayajbe'lu'. Type (r)uch to proceed or (q)Il to cancel." ;;
        esac
    done
fi

echo "Extracting archive…"

tar -C $OSS_DIR -xf "$MODEL_FILE"

if [ $? ]; then
    echo "Qapla'! Voice model successfully imported."
else
    echo "Qagh! Failed to import voice model."
    exit 1
fi
