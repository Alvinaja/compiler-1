 #!/bin/bash

# Copyright (C) 2021 a xyzprjkt property

# Warning !! Dont Change anything there without known reason.
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
#PATH="${HOME}/clang/bin:${PATH}" \
make -j$(nproc) ARCH=arm64 O=out \
	CC=clang \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_COMPILE_ARM32=arm-linux-gnueabi-
