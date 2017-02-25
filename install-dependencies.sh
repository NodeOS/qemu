#!/usr/bin/env bash

#
# This file install the system dependencies needed to build QEmu. It should be
# of interest only when generating prebuild releases
#

set -o pipefail

if [[ -f /etc/debian_version ]]; then
  APT='apt-get -qq -y'

  # Update cache
  #dpkg --add-architecture i386  &&
  #dpkg --add-architecture amd64 &&
  $APT update                   || exit 1

  #$APT install libsdl1.2-dev:i386  zlib1g-dev:i386  \
  #             libsdl1.2-dev:amd64 zlib1g-dev:amd64 || exit 20
  $APT install libsdl1.2-dev zlib1g-dev || exit 20
fi

if [[ $(uname -s) = "Darwin" ]]; then
  command -v port >/dev/null ||
  (
    echo "MacPorts is not installed" &&
    echo "Please visit https://www.macports.org/ for more information" &&
    exit 40
  )

  PORT='port -q'

  $PORT selfupdate || exit 41

  $PORT install glib2 || exit 43

  $PORT install libpixman || exit 44
fi
