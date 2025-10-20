ffmpeg -i how_it_works.mp4 \
  -an \
  -c:v libx264 -preset medium -crf 22 -profile:v high -level 4.0 -pix_fmt yuv420p \
  -vf "scale=1280:-2" -r 30 \
  -g 60 -keyint_min 60 -sc_threshold 0 \
  -movflags +faststart \
  how_it_works.mp4
