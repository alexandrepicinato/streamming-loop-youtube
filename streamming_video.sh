#!/bin/bash

VIDEO_DIR="/home/ninjacat/DJIFly"
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2/SUA_CHAVE_AQUI"

while true; do
  for video in "$VIDEO_DIR"/*.mp4; do
    echo "[*] Transmitindo: $video"
    
    ffmpeg -re -i "$video" \
      -i rtmp://localhost/live/audio \
      -filter_complex "[0:v]fps=30,scale=1280:720[v]" \
      -map "[v]" -map 1:a \
      -c:v libx264 -preset ultrafast -b:v 2500k -maxrate 2500k -bufsize 5000k \
      -c:a aac -b:a 128k -ar 44100 \
      -threads 0 \
      -f flv "$YOUTUBE_URL"

    echo "[*] Vídeo finalizado: $video"
  done
done
