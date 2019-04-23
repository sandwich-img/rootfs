#!/bin/sh

set -xe

DEBIAN_BRANCH=$BRANCH
DEBIAN_ARCH=$ARCH
UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"
PORTS_MIRROR="http://ports.ubuntu.com/"

mkdir -p mnt/rootfs

case $DEBIAN_ARCH in
	arm* ) MIRRORS=$PORTS_MIRROR ;;
	i386 | amd64 ) MIRRORS=$UBUNTU_MIRROR ;;
esac

debootstrap --no-check-gpg --arch=$DEBIAN_ARCH $DEBIAN_BRANCH mnt/rootfs "$MIRRORS"
