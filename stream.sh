
# === CONFIGURAÇÕES ===
VIDEO_DIR="/home/ninjacat/video"
AUDIO_FILE="/home/ninjacat/song/audio1.mp3"
YOUTUBE_KEY="y3g8-22ag-cg75-k8f0-93cf"  # Exemplo: abcd-efgh-1234-5678
RTMP_URL="rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_KEY"
FPS=30

# Aceita extensões em .mp4 e .MP4
shopt -s nullglob
VIDEOS=( "$VIDEO_DIR"/*.mp4 "$VIDEO_DIR"/*.MP4 )

# Verificação de arquivos
if [ ${#VIDEOS[@]} -eq 0 ]; then
  echo "❌ Nenhum vídeo encontrado em $VIDEO_DIR"
  exit 1
fi

if [ ! -f "$AUDIO_FILE" ]; then
  echo "❌ Arquivo de áudio não encontrado: $AUDIO_FILE"
  exit 1
fi

# === LOOP DE TRANSMISSÃO ===
while true; do
  for VIDEO in "${VIDEOS[@]}"; do
    echo "🎥 Transmitindo: $VIDEO para o YouTube"
    ffmpeg -re -i "$VIDEO" -stream_loop -1 -i "$AUDIO_FILE" \
      -shortest -r $FPS -c:v libx264 -preset ultrafast -b:v 2500k \
      -c:a aac -b:a 128k -f flv "$RTMP_URL"
    echo "[*] Finalizado: $VIDEO"
  done
done

