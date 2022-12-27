#!/bin/bash

# vars yourself
DEFCONFIG=merlin_defconfig
AK=https://github.com/Alvinaja/AnyKernel3
ZIPNAME="Kernel-2080"

# telegram env
ID=-1001599080496

echo "Prepare dependencies"
mkdir clang-llvm
mkdir gcc64-aosp
mkdir gcc32-aosp
wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r445002.tar.gz "clang-r445002.tar.gz"
tar -xf clang-r445002.tar.gz -C $(pwd)/clang-llvm
wget -q https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/android-12.0.0_r32.tar.gz -O "gcc64.tar.gz"
tar -xf gcc64.tar.gz -C $(pwd)/gcc64-aosp
wget -q https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/refs/tags/android-12.0.0_r32.tar.gz -O "gcc32.tar.gz"
tar -xf gcc32.tar.gz -C $(pwd)/gcc32-aosp
git clone $AK --depth=1 AnyKernel

echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
PATH="${KERNEL_DIR}/clang-llvm/bin:${KERNEL_DIR}/gcc64-aosp/bin:${KERNEL_DIR}/gcc32-aosp/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang-llvm/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=Alpin
export KBUILD_BUILD_HOST=Gajelas

make O=out ARCH=arm64 $DEFCONFIG

# Compile plox
function compile() {
    make -j$(nproc --all) O=out ARCH=arm64 CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CROSS_COMPILE_ARM32=arm-linux-androideabi-

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $ZIPNAME-${TANGGAL}.zip *
    cd ..
}

function start() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build started on $(date) with $KBUILD_COMPILER_STRING"
}
# Push kernel to channel

function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="OSS Kernel | Build finished on $(date)"
}
# Fin Error

function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

start
compile
zipping
push
