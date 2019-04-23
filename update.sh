#!/bin/sh
#
# This script running on linux amd64 platform, generate rootfs and
# build base image for imghub(https://hub.docker.com/r/sandwichimg)
#

set -xe

for DEPS in docker wget curl grep strings tar xz ; do
	which $DEPS > /dev/null || exit 
done

if [ "$(id -u)" -ne 0 ]; then
	die 'This script must be run as root!'
fi

usage() {
	cat <<EOF
	Usage: ./update.sh [options]

	Example:
		sudo ./update.sh -d alpine -a x86_64 -b edge

	Options and environment variables:
	-d DISTRO              Linux distribution(alpine/debian/deepin/ubuntu).
	-a ARCH                CPU architecture for the distribution.
	-b BRANCH              Linux distribution branch.
	-h                     Show this help message and exit.
EOF
}

while getopts 'a:b:d:h' OPTION; do
	case "$OPTION" in
		a) ARCH="$OPTARG";;
		b) BRANCH="$OPTARG";;
		d) DISTRO="$OPTARG";;
		h) usage; exit 0;;
	esac
done

: ${ALPINE_BRANCH:="edge"}
: ${ALPINE_MIRROR:="http://mirror.leaseweb.com/alpine"}
: ${ALPINE_PACKAGES:="apk-tools-static debootstrap perl"}
: ${ARCH:=}
: ${ALPINE_ARCH:=}
: ${ALPINE_CHROOT:="alpine_chroot"}
: ${QEMU_VER:="v3.1.0-3"}
: ${TEMP_DIR:="tmp"}


normalize_alpine_arch() {
	case "$1" in
		armv7h) echo 'armv7'  ;;
		arm64 ) echo 'aarch64';;
		 i386 ) echo 'x86'	  ;;
		amd64 ) echo 'x86_64' ;;
		*) echo "$1";;
	esac
}

normalize_qemu_arch() {
	case "$1" in
		armhf | armv7 ) echo 'arm'	;;
		arm64 ) echo 'aarch64';;
		*) echo "$1";;
	esac
}

ALPINE_ARCH="$(normalize_alpine_arch $ARCH)"

QEMU_ARCH="$(normalize_qemu_arch $ARCH)"

QEMU_URI="https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VER}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz"

mkdir -p $TEMP_DIR/$ALPINE_ARCH $ALPINE_CHROOT/$ALPINE_ARCH/usr/bin

# download apk.static
if [ ! -f $TEMP_DIR/$ALPINE_ARCH/apk.static ]; then
	apkv=$(curl -sSL "$ALPINE_MIRROR"/$ALPINE_BRANCH/main/$ALPINE_ARCH/APKINDEX.tar.gz | tar -Oxz | strings |
	grep '^P:apk-tools-static$' -A1 | tail -n1 | cut -d: -f2)
	curl -sSL "$ALPINE_MIRROR"/$ALPINE_BRANCH/main/$ALPINE_ARCH/apk-tools-static-${apkv}.apk | tar -xz -C $TEMP_DIR/$ALPINE_ARCH sbin/apk.static --strip=1
fi

mkdir -p "$ALPINE_CHROOT"/$ALPINE_ARCH/usr/bin "$ALPINE_CHROOT"/$ALPINE_ARCH/mnt/rootfs/usr/bin
	
case $ARCH in
	arm* | aarch64) if [ ! -f x86_64_qemu-${QEMU_ARCH}-static.tar.gz ]; then
		wget "$QEMU_URI"
	fi
	
	if [ ! -f "$ALPINE_CHROOT"/$ALPINE_ARCH/usr/bin/qemu-$QEMU_ARCH-static ]; then
		tar -xvf x86_64_qemu-${QEMU_ARCH}-static.tar.gz -C "$ALPINE_CHROOT"/$ALPINE_ARCH/usr/bin
	fi
	
	if [ ! -f "$ALPINE_CHROOT"/$ALPINE_ARCH/mnt/rootfs/usr/bin/qemu-$QEMU_ARCH-static ]; then
		cp "$ALPINE_CHROOT"/$ALPINE_ARCH/usr/bin/qemu* "$ALPINE_CHROOT"/$ALPINE_ARCH/mnt/rootfs/usr/bin
	fi
	
	;;
esac

install_alpine_chroot() {

mkdir -p "$ALPINE_CHROOT"/$ALPINE_ARCH/etc/apk

printf '%s\n' \
	"$ALPINE_MIRROR/$ALPINE_BRANCH/main" \
	"$ALPINE_MIRROR/$ALPINE_BRANCH/community" \
	> "$ALPINE_CHROOT"/$ALPINE_ARCH/etc/apk/repositories

cp /etc/resolv.conf "$ALPINE_CHROOT"/$ALPINE_ARCH/etc/resolv.conf
	
$TEMP_DIR/$ALPINE_ARCH/apk.static --update-cache --allow-untrusted \
	--root $ALPINE_CHROOT/$ALPINE_ARCH --initdb add alpine-base $ALPINE_PACKAGES --verbose
}

if [ ! -f $ALPINE_CHROOT/$ALPINE_ARCH/etc/os-release ]; then
	install_alpine_chroot
fi

cp $DISTRO/gen-rootfs.sh $ALPINE_CHROOT/$ALPINE_ARCH
	
mount -t proc none $ALPINE_CHROOT/$ALPINE_ARCH/proc
mount -o bind /sys $ALPINE_CHROOT/$ALPINE_ARCH/sys
mount -o bind /dev $ALPINE_CHROOT/$ALPINE_ARCH/dev

ARCH=$ARCH BRANCH=$BRANCH chroot $ALPINE_CHROOT/$ALPINE_ARCH /gen-rootfs.sh

umount -l $ALPINE_CHROOT/$ALPINE_ARCH/proc
umount -l $ALPINE_CHROOT/$ALPINE_ARCH/sys
umount -l $ALPINE_CHROOT/$ALPINE_ARCH/dev

case $ARCH in
	arm* | aarch64) rm -rf $ALPINE_CHROOT/$ALPINE_ARCH/mnt/rootfs/usr/bin/qemu* ;;
esac

tar --numeric-owner --create --auto-compress --file $ALPINE_CHROOT/$ALPINE_ARCH/mnt/rootfs.tar.xz --directory $ALPINE_CHROOT/$ALPINE_ARCH/mnt/rootfs --transform='s,^./,,' . &&
mkdir -p $DISTRO/$BRANCH/$ARCH &&
mv $ALPINE_CHROOT/$ALPINE_ARCH/mnt/rootfs.tar.xz $DISTRO/$BRANCH/$ARCH

rm -rf $ALPINE_CHROOT/$ALPINE_ARCH/mnt/rootfs $ALPINE_CHROOT/$ALPINE_ARCH/gen-rootfs.sh

cat > $DISTRO/$BRANCH/$ARCH/Dockerfile <<EOF
FROM scratch
ADD rootfs.tar.xz /
EOF

case $ARCH in
	arm* | aarch64) echo "ADD x86_64_qemu-*-static.tar.gz /usr/bin" >> $DISTRO/$BRANCH/$ARCH/Dockerfile && cp x86_64_qemu-${QEMU_ARCH}-static.tar.gz $DISTRO/$BRANCH/$ARCH ;;
esac

docker build -t sandwichimg/$DISTRO:$ARCH-$BRANCH $DISTRO/$BRANCH/$ARCH
