#!/bin/bash
set -euxo pipefail

function shutdown {
  kill -s SIGTERM $NODE_PID
  wait $NODE_PID
}

function get_server_num() {
  echo $(echo $DISPLAY | sed -r -e 's/([^:]+)?:([0-9]+)(\.[0-9]+)?/\2/')
}

export SCREEN_WIDTH="${SCREEN_WIDTH:-1920}"
export SCREEN_HEIGHT="${SCREEN_HEIGHT:-1080}"
export SCREEN_DEPTH="${SCREEN_DEPTH:-24}"
export DISPLAY=":99.0"
export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"
export SERVERNUM=$(get_server_num)
export DBUS_SESSION_BUS_ADDRESS=/dev/null
export PATH="/opt/wine-stable/bin:${PATH}"
export WINEPREFIX=/srv/wine

# clean-up
rm -f /tmp/xvfb.auth /tmp/.X*lock

umask 0022

xvfb-run --auth-file /tmp/xvfb.auth -n $SERVERNUM \
  --server-args="-screen 0 $GEOMETRY -ac +extension RANDR" \
  openbox-session &
NODE_PID=$!

timeout=10 # seconds
while ! xset q &>/dev/null && [ $timeout -gt 0 ]; do sleep 1 ; timeout=$[timeout-1] ; done

x11vnc -rfbport 5999 -display :$SERVERNUM -forever -auth /tmp/xvfb.auth \
  -desktop $NODE &

trap shutdown SIGTERM SIGINT
wait $NODE_PID
