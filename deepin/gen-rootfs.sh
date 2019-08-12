#!/bin/sh

set -xe

DEBIAN_BRANCH=$BRANCH
DEBIAN_ARCH=$ARCH
DEEPIN_MIRROR="http://packages.deepin.com/deepin/"
if [ ! -f /usr/share/debootstrap/scripts/$DEBIAN_BRANCH ]; then

        cat > /usr/share/debootstrap/scripts/$DEBIAN_BRANCH <<'EOF'
mirror_style release
download_style apt
finddebs_style from-indices
variants - buildd fakechroot minbase
keyring /usr/share/keyrings/deepin-archive-keyring.gpg

# include common settings
if [ -e "$DEBOOTSTRAP_DIR/scripts/debian-common" ]; then
 . "$DEBOOTSTRAP_DIR/scripts/debian-common"
elif [ -e /debootstrap/debian-common ]; then
 . /debootstrap/debian-common
else
 error 1 NOCOMMON "File not found: debian-common"
fi
EOF

fi

mkdir -p mnt/rootfs

debootstrap --no-check-gpg --arch=$DEBIAN_ARCH $DEBIAN_BRANCH mnt/rootfs "$DEEPIN_MIRROR"
