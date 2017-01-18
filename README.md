# auto-bpm-analyzer
Automatic BPM (beats per minute) detection for music -- batch process and tag a folder of tracks.

## Usage

`./bpm-analyze.sh`

`bpm-analyze.sh` will detect the tempo of all audio files in the current directory, and tag them.

## Requirements

Requires `bpm-tools`, `AtomicParsley`, `ffmpeg`, and `sox`.

Currently only processes mp3 and m4a audio files (this is very easy to change).
