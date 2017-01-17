#!/bin/bash

# Automatically tag a folder of music with an auto-detected tempo in BPM
# Usage: ./bpm-analyze.sh
# With no arguments, searches for tracks in the current folder and attempts to tag them

which bpm-tag >/dev/null || {
	echo "Please install 'bpm-tools' (http://www.pogo.org.uk/~mark/bpm-tools/)"
  exit 1
	} # Check for bpm-tools
  
which ffmpeg >/dev/null || {
	echo "Please install 'ffmpeg'"
  exit 1
	} # Check for ffmpeg
  
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