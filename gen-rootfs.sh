#!/bin/sh

set -xe

mkdir -p $DEBIAN_BRANCH/$ARCH

if [ ! -f /usr/share/debootstrap/scripts/panda ]; then
	wget -P /usr/share/debootstrap/scripts https://github.com/bestwu/docker-deepin/raw/master/panda
fi

debootstrap --no-check-gpg --arch=$ARCH $DEBIAN_BRANCH $DEBIAN_BRANCH/$ARCH/rootfs http://packages.deepin.com/deepin/ &&
tar --numeric-owner --create --auto-compress --file $DEBIAN_BRANCH/$ARCH/rootfs.tar.xz --directory $DEBIAN_BRANCH/$ARCH/rootfs --transform='s,^./,,' . &&
rm -rf $DEBIAN_BRANCH/$ARCH/rootfs
