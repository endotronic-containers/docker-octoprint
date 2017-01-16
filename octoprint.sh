#!/bin/sh
set -ex
unset OCTOPRINT_VERSION

export STREAMER_FLAGS=""
if [ ${YUV_CAMERA} = 'true' ]; then
  export STREAMER_FLAGS="-y"
fi

export CAMERA_DEV="/dev/video0"

if [ -e "${CAMERA_DEV}" ]; then
  mjpg_streamer -i "/usr/local/lib/input_uvc.so ${STREAMER_FLAGS} -r 640x480 -d ${CAMERA_DEV}" -o "/usr/local/lib/output_http.so -w /usr/local/www -p 8088" &
  streamer=$!
  sleep 1
else
  echo "No Camera found (should be bounded to /dev/video0)"
fi

exec octoprint  --iknowwhatimdoing --basedir /data
if [[ -e ${CAMERA_DEV} ]]; then
  kill -9 ${streamer}
  wait ${streamer}
fi