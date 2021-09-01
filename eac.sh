#!/bin/bash
# vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

set -euo pipefail

# docker-eac settings
RC=./eac.rc

function gen_header() {
cat <<EOD
---
version: '2'
services:

EOD
}

function gen_drive() {
cat <<EOD
# $driveid
  $drivename:
    image: docker.eac:v1.0
    build:
      context: .
    ports:
      - $vnc:5999
    environment:
      - NODE=$drivename
      - SCREEN_WIDTH=$SCREEN_WIDTH
      - SCREEN_HEIGHT=$SCREEN_HEIGHT
      - UID=$(id -u)
      - GID=$(id -g)
    devices:
      - "$sr:/dev/sr0:rwm"
    volumes:
     - $SHARE:/data
     - $WINEROOT/$drivename:/srv/wine

EOD
}

if [ -s "$RC" ]
then
  source "$RC"
else
  echo "ERROR: $0: RC file $RC not found"
  exit 1
fi

if ! [ -s "$DRIVECFG" ]
then
  echo "ERROR: $0: drive config $DRIVECFG not found"
  exit 1
fi

# tear down old stack if present
if [ -s "$COMPOSEFILE" ]
then
  docker-compose -f "$COMPOSEFILE" -p eac down || :
fi

port=11
gen_header > "$COMPOSEFILE"
vnctmp=$(mktemp)
declare -i i=0
while read -r drivename driveid
do
  # check if drive exists
  if [ -h "/dev/disk/by-id/$driveid" ]
  then
    i=$[i+1]
    sr=$(readlink -f "/dev/disk/by-id/$driveid")
    echo "$(hostname --fqdn):$port $drivename" >> $vnctmp
    vnc=$[5900+port]
    gen_drive >> "$COMPOSEFILE"
    port=$[port+1]
    mkdir -p "$WINEROOT/$drivename"
  fi
done < "$DRIVECFG"

if [[ $i -gt 0 ]]
then
  docker-compose -f "$COMPOSEFILE" -p eac up -d
  echo ""
  echo "VNC screens:"
  cat "$vnctmp"
  rm -f "$vnctmp"
  echo ""
  echo "Press ENTER to drop the stack..."
  read enter
  docker-compose -f "$COMPOSEFILE" -p eac down && rm -f "$COMPOSEFILE"
else
  rm -f "$COMPOSEFILE"
  echo "ERROR: $0: No CD-ROM drives found"
fi

echo "GOOD BYE!"
