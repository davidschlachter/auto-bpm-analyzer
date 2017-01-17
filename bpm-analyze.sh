#!/bin/bash

# Automatically tag a folder of music with an auto-detected tempo in BPM
# Usage: ./bpm-analyze.sh
# With no arguments, searches for tracks in the current folder and attempts to tag them

which bpm-tag || {
	echo "Please install 'bpm-tools' (http://www.pogo.org.uk/~mark/bpm-tools/)"
  exit 1
	} # Check for bpm-tools
  
which ffmpeg || {
	echo "Please install 'ffmpeg'"
  exit 1
	} # Check for ffmpeg
  
