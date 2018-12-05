#!/bin/sh

set -xe

mkdir -p $DEBIAN_BRANCH/$ARCH

debootstrap --no-check-gpg --arch=$ARCH $DEBIAN_BRANCH $DEBIAN_BRANCH/$ARCH/rootfs &&
tar --numeric-owner --create --auto-compress --file $DEBIAN_BRANCH/$ARCH/rootfs.tar.xz --directory $DEBIAN_BRANCH/$ARCH/rootfs --transform='s,^./,,' . &&
rm -rf $DEBIAN_BRANCH/$ARCH/rootfs
