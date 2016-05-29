#!/usr/bin/env bash

#
# This file install the system dependencies needed to build QEmu. It should be
# of interest only when generating prebuild releases
#

set -o pipefail

APT='apt-get -qq -y'

# Update cache
#dpkg --add-architecture i386  &&
#dpkg --add-architecture amd64 &&
$APT update                   || exit 1

#$APT install libsdl1.2-dev:i386  zlib1g-dev:i386  \
#             libsdl1.2-dev:amd64 zlib1g-dev:amd64 || exit 20
$APT install libsdl1.2-dev zlib1g-dev || exit 20
