#!/bin/sh

# usage: ./speech_to_text.sh inputfilename.m4a

set -e # exit from failure

export GOOGLE_APPLICATION_CREDENTIALS=democracy\ in\ 21st\ century-74fff096df4f.json

INFILE=$1

OUTPUT="$(basename $INFILE .m4a).csv"
echo "$OUTPUT"
echo "" > $OUTPUT
mkdir -p tmp
echo "processing $INFILE"

rm -f tmp/*
ffmpeg -i $INFILE -loglevel 0 -f segment -segment_time 300 -c copy tmp/%03d.m4a

for f in tmp/*.m4a; do
	echo "processing $f"
	outfile="$(basename $f .m4a).wav"
	ffmpeg -loglevel 0 -i $f -ar 16000 -ac 1 -sample_fmt s16 -acodec pcm_s16le -f wav "tmp/$outfile"
	gsutil cp "tmp/$outfile" gs://democracy-in-21st-century.appspot.com
	python transcribe_async.py --encoding LINEAR16 "gs://democracy-in-21st-century.appspot.com/$outfile" >> $OUTPUT
done

echo "all good"
