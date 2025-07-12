#!/bin/bash

# CONFIGURAÇÕES
VIDEO_DIR="/home/ninjacat/DJIFly"
AUDIO_FILE="/home/ninjacat/audio.mp3"
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2/g760-k6cf-gsxt-vwg0-96ky"

#RTMP LOCAL 
start_nginx_rtmp() {
cat > /etc/nginx/nginx.conf <<EOF
worker_processes auto;
events {
    worker_connections 1024;
}
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        application live {
            live on;
            record off;
        }
    }
}
EOF

nginx -t && systemctl restart nginx || nginx
}


#AUDIO ENCODE ----
start_audio_stream() {
  ffmpeg -re -stream_loop -1 -i "$AUDIO_FILE" \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv rtmp://localhost/live/audio &
  AUDIO_PID=$!
}


#VIDEO ENCODE 
stream_videos() {
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
}

# EXECUÇÃO
echo "[+] Iniciando RTMP local com nginx"
start_nginx_rtmp

echo "[+] Iniciando áudio em loop"
start_audio_stream

echo "[+] Iniciando stream de vídeos"
stream_videos
