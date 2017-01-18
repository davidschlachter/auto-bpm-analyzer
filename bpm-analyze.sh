#!/bin/bash

# Automatically tag a folder of music with an auto-detected tempo in BPM
# Usage: ./bpm-analyze.sh
# With no arguments, searches for tracks in the current folder and attempts to tag them

# Minimum and maximum BPM to be detected:
MIN=40
MAX=350

# Any extra options to pass to bpm-tools when processing mp3 files only
# (e.g. -n for dry run, -f to overwrite existing BPM tag)
OPTIONS="-n"

which bpm-tag >/dev/null || {
	echo "ERROR: Please install 'bpm-tools' (http://www.pogo.org.uk/~mark/bpm-tools/)"
  exit 1
	} # Check for bpm-tools
  
which sox >/dev/null || {
	echo "ERROR: Please install 'sox' (mp3 support required)"
  exit 1
	} # Check for sox

which ffmpeg >/dev/null || {
	echo "ERROR: Please install 'ffmpeg'"
  exit 1
	} # Check for ffmpeg
  
which AtomicParsley >/dev/null || {
	echo "WARNING: 'AtomicParsley' is required for M4A support"
  } # Check for AtomicParsley
  
if (( ${BASH_VERSION%%.*} < 4 )); then
  echo "'bash' version must be greater than or equal to 4"
  exit 1
fi

# Enumerate audio files in the current directory
# (verify that there are audio files to process)
find ./ | grep '\.mp3$\|\.mp4$\|\.m4a$\|\.wav$\|\.pcm$\|\.aif$\|\.aiff$\|\.aac$\|\.ogg$\|\.wma$\|\.flac$\|\.alac$' > /dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "The current directory must contain the audio files to process."
  exit 1
fi

# Process all MP3 files (this is easy)
find ./ | grep '\.mp3$' > /dev/null 2>&1
if [ "$?" = "0" ]; then
  for f in *.mp3; do
    bpm-tag $OPTIONS -m $MIN -x $MAX "$f"
  done
fi

# Process everything else by converting it to MP3
# Currently, only m4a is actually supported  :)
find ./ | grep '\.m4a$' > /dev/null 2>&1
if [ "$?" = "0" ]; then
  for f in *.m4a; do
    echo "-----------------------------------------------------------"
    MP3FILE="`basename "$f" .m4a`.mp3"
    ffmpeg -loglevel panic -i "$f" -codec:a libmp3lame -b:a 192k "$MP3FILE"
    OUTPUT="$(sox -t mp3 "$MP3FILE" -t raw -r 44100 -e float -c 1 /dev/stdout | bpm -m $MIN -x $MAX -f "%0.f")"
    if [[ "$OUTPUT" =~ ^-?[0-9]+$ ]]; then
      TEMP=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
      echo "BPM was $OUTPUT for $f"
      AtomicParsley "$f" --bpm $OUTPUT --output "$TEMP".m4a >/dev/null
      mv "$TEMP".m4a "$f"
    else
      echo "WARNING: $f could not be processed. BPM was not an integer."
      echo "         Output of bpm was: $OUTPUT"
    fi
    rm "$MP3FILE"
  done
  echo "-----------------------------------------------------------"
fi

# Warn if audio files were present in unsupported formats
find ./ | grep '\.mp4$\|\.wav$\|\.pcm$\|\.aif$\|\.aiff$\|\.aac$\|\.ogg$\|\.wma$\|\.flac$\|\.alac$' > /dev/null 2>&1
if [ "$?" = "0" ]; then
  echo "WARNING: Only mp3 and m4a files are currently supported. Some files were not processed."
  exit 1
fi
