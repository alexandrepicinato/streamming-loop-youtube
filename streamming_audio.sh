#!/bin/bash

AUDIO="/home/ninjacat/audio.mp3"
while true; do
  ffmpeg -re -stream_loop -1 -i "$AUDIO" \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv rtmp://localhost/live/audio
done
