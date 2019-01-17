.PHONY: armv7h
armv7h:
	ARCH=armv7h ./build.sh

.PHONY: aarch64
aarch64:
	ARCH=aarch64 ./build.sh

.PHONY: x86_64
x86_64:
	ARCH=x86_64 ./build.sh

all: armv7h aarch64 x86_64

