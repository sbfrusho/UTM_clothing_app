#!/bin/sh
# Builds docs/media/app-tour.mp4 (1080x1920) and a small README preview GIF
# from the slides in tool/app_tour/slides. Needs ffmpeg.
#
#   flutter test tool/screenshots_test.dart --update-goldens
#   flutter test tool/app_tour/slides_test.dart --update-goldens
#   sh tool/app_tour/make_video.sh
set -eu
cd "$(dirname "$0")/../.."

SLIDE=2.6   # seconds each slide is fully visible
FADE=0.5    # crossfade length
OUT=docs/media
mkdir -p "$OUT"

set -- tool/app_tour/slides/*.png
n=$#
inputs=""
for f in "$@"; do
  inputs="$inputs -loop 1 -framerate 30 -t $(echo "$SLIDE + $FADE" | bc) -i $f"
done

# Chain of crossfades: [0][1] -> v1, [v1][2] -> v2, ...
filter=""
prev="0:v"
offset=0
i=1
while [ "$i" -lt "$n" ]; do
  offset=$(echo "$offset + $SLIDE" | bc)
  filter="$filter[$prev][$i:v]xfade=transition=fade:duration=$FADE:offset=$offset[v$i];"
  prev="v$i"
  i=$((i + 1))
done
filter="$filter[$prev]format=yuv420p[out]"

# shellcheck disable=SC2086
ffmpeg -y -loglevel error $inputs -filter_complex "$filter" -map "[out]" \
  -c:v libx264 -preset slow -crf 20 -r 30 -movflags +faststart \
  "$OUT/app-tour.mp4"

ffmpeg -y -loglevel error -i "$OUT/app-tour.mp4" \
  -vf "fps=12,scale=360:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96[p];[b][p]paletteuse=dither=bayer:bayer_scale=4" \
  "$OUT/app-tour.gif"

ls -lh "$OUT/app-tour.mp4" "$OUT/app-tour.gif"
