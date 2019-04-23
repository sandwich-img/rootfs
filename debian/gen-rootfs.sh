#!/bin/sh

set -xe

DEBIAN_BRANCH=$BRANCH
DEBIAN_ARCH=$ARCH
DEBIAN_MIRROR="http://deb.debian.org/debian"

mkdir -p mnt/rootfs

debootstrap --no-check-gpg --arch=$DEBIAN_ARCH $DEBIAN_BRANCH mnt/rootfs "$DEBIAN_MIRROR"
