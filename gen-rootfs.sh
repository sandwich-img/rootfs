#!/bin/sh

set -xe

mkdir -p $ARCH

pacstrap $ARCH base base-devel &&
tar --numeric-owner --create --auto-compress --file $ARCH/rootfs.tar.xz --directory $ARCH/rootfs --transform='s,^./,,' . &&
rm -rf $ALPINE_BRANCH/$ARCH/rootfs
