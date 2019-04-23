#!/bin/sh

set -xe

ALPINE_BRANCH=$BRANCH
ALPINE_ARCH=$ARCH

mkdir -p mnt/rootfs

apk.static -X http://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH}/main -U --allow-untrusted --root mnt/rootfs --initdb add alpine-base
