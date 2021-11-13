#!/bin/bash

# Copyright (C) 2021 a xyzprjkt property

# Main
KERNEL_ROOTDIR=$HOME/lancetod # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_DEFCONFIG=lancelot_defconfig # IMPORTANT ! Declare your kernel source defconfig file here.
CLANG_ROOTDIR=${HOME}/clang
export KBUILD_BUILD_USER=voidXkernel # Change with your own name or else.
export KBUILD_BUILD_HOST=cau@void # Change with your own hostname.
