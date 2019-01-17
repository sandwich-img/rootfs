#!/bin/sh

set -xe

mkdir -p $ARCH/rootfs

pacstrap $ARCH/rootfs base &&
tar --numeric-owner --create --auto-compress --file $ARCH/rootfs.tar.xz --directory $ARCH/rootfs --transform='s,^./,,' . &&
rm -rf $ARCH/rootfs
