#!/bin/sh

set -xe

case $ARCH in
	armv7h | aarch64) BASE_IMG=yangxuan8282/archlinuxarm:$ARCH;;
	x86_64) BASE_IMG=base/archlinux;;
esac

mkdir -p $ARCH

docker run --rm -ti --privileged -v $(pwd)/$ARCH:/mnt -v $(pwd)/gen-rootfs.sh:/gen-rootfs.sh $BASE_IMG /gen-rootfs.sh
