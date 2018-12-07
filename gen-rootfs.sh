#!/bin/sh

set -xe

mkdir -p $ALPINE_BRANCH/$ARCH

apk.static -X http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_BRANCH}/main -U --allow-untrusted --root ${ALPINE_BRANCH}/$ARCH/rootfs --initdb add alpine-base &&
tar --numeric-owner --create --auto-compress --file $ALPINE_BRANCH/$ARCH/rootfs.tar.xz --directory $ALPINE_BRANCH/$ARCH/rootfs --transform='s,^./,,' . &&
rm -rf $ALPINE_BRANCH/$ARCH/rootfs
