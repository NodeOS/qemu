#!/usr/bin/env bash

set -o pipefail


TARGET_LIST=aarch64-softmmu,arm-softmmu,i386-softmmu,x86_64-softmmu
TARGET_USER=aarch64-linux-user,arm-linux-user,i386-linux-user,x86_64-linux-user

QEMU_VERSION=`node -p "require('./package.json').version"`

QEMU_URL=https://download.qemu.org/qemu-$QEMU_VERSION.tar.bz2


if [[ -z $JOBS ]]; then
  JOBS=$((`getconf _NPROCESSORS_ONLN` + 1))
fi

if [[ -z $MACHINE ]]; then
  MACHINE=`uname -m`
fi
case $MACHINE in
  i[345678]86)
    ARCH=ia32
#    CC="cc -m32"
#    CXX="cpp -m32"
  ;;

  x86_64)
    ARCH=x64
#    CC="cc -m64"
#    CXX="cpp -m64"
  ;;

  *)
    echo Unknown MACHINE "$MACHINE"
    exit 1
  ;;
esac


OS="`uname`"
case $OS in
  'Linux')
    PLATFORM=linux
    AUDIO=alsa
    TARGET_LIST+=,$TARGET_USER
    DISPLAY=sdl
    PRODUCTS=(bin libexec share)
  ;;

  'FreeBSD')
    PLATFORM=freebsd
  ;;

  'WindowsNT')
    PLATFORM=win
  ;;

  'Darwin')
    PLATFORM=darwin
    AUDIO=coreaudio
    DISPLAY=cocoa
    PRODUCTS=(bin share)
  ;;

  'SunOS')
    PLATFORM=solaris
  ;;

  'AIX')
    PLATFORM=linux
    AUDIO=alsa
    TARGET_LIST+=,$TARGET_USER
    DISPLAY=sdl
    PRODUCTS=(bin libexec share)
  ;;

  *)
    echo Unknown OS "$OS"
    exit 2
  ;;
esac


function rmStep(){
  rm -rf "$@"
}

# Clean object dir and return the input error
function err(){
  rmStep $STEP_DIR
  exit $1
}


#
# Define steps paths
#

SRC_DIR=`pwd`/deps/qemu
OBJ_DIR=build/$MACHINE
OUT_DIR=`pwd`
PREBUILD=prebuilds/$PLATFORM-$ARCH.tar.gz


#
# Download QEmu
#

STEP_DIR=$SRC_DIR

if [[ ! -d $STEP_DIR ]]; then
  mkdir -p $STEP_DIR || exit 3

  rmStep $OBJ_DIR

  curl $QEMU_URL | tar -xj --strip-components=1 -C $STEP_DIR || err 4
fi


#
# Build qemu
#

STEP_DIR=$OBJ_DIR

if [[ ! -d $STEP_DIR ]]; then
  rmStep $PREBUILD ${PRODUCTS[@]} var

  (
    mkdir -p $STEP_DIR &&
    cd       $STEP_DIR || exit 5


    $SRC_DIR/configure --prefix=$OUT_DIR          \
                       --cpu=$MACHINE             \
                       --target-list=$TARGET_LIST \
                       --audio-drv-list=$AUDIO    \
                       --disable-bzip2            \
                       --disable-docs             \
                       --disable-gcrypt           \
                       --disable-gnutls           \
                       --disable-lzo              \
                       --disable-snappy           \
                       --disable-vnc              \
                       --disable-xen              \
                       --enable-$DISPLAY          || exit 6
#                       --static                   \

    make -j$JOBS &&
    make install || exit 7
  ) || err $?
fi


#
# Pack qemu in a node-gyp compatible way
#

STEP_DIR=$PREBUILD

mkdir -p prebuilds                          &&
tar -cf - ${PRODUCTS[@]} | gzip > $PREBUILD || err 8
