#!/bin/sh

set -xe

mkdir -p mnt/rootfs
pacman -Syu --noconfirm arch-install-scripts tar

ARCH=$(uname -m)

case $ARCH in
	arm* | aarch64) mkdir -p mnt/rootfs/usr/bin && cp /usr/bin/qemu* mnt/rootfs/usr/bin/ ;;
esac

pacstrap mnt/rootfs base &&

case $ARCH in
        arm* | aarch64) rm -rf mnt/rootfs/usr/bin/qemu* ;;
esac

tar --numeric-owner --create --auto-compress --file mnt/rootfs.tar.xz --directory mnt/rootfs --transform='s,^./,,' . &&
rm -rf mnt/rootfs
