#!/usr/bin/env bash
# Copyright (C) 2020-2021 Oktapra Amtono
# Docker Kernel Build Script

# Telegram ID
export CHANNEL_ID="-1001448019349"

# Setup Environtment
export TZ="Asia/Jakarta"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
KERNEL_DIR=$PWD
ZIP_DATE=$(TZ=Asia/Jakarta date +'%H-%M-%S')
KERNEL_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb

# Kernel & Clang Setup
CLANG_DIR="$KERNEL_DIR/mystic-clang"
export PATH="/mystic-clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${CLANG_DIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="okta_10"
export KBUILD_BUILD_HOST="CircleCI"

# Telegram
TELEGRAM=Telegram/telegram
sendKernel() {
  "${TELEGRAM}" -f "$(echo "$AK3_DIR"/*.zip)" \
  -c "${CHANNEL_ID}" -H \
      "$(echo "$DEVICE - $CODENAME ($CAM_BLOB)")"
}

# Setup Defconfig
# if whyred
if [[ "$@" =~ "whyredoldcam" ]]; then
  export DEVICE="Redmi Note 5 Pro / AI"
  export CODENAME="Whyred"
  AK3_DIR=$KERNEL_DIR/ak3-whyred/
  export KERNEL_DEFCONFIG=mystic-whyred-oldcam_defconfig
  export CAM_BLOB="OldCam"
elif [[ "$@" =~ "whyrednewcam" ]]; then
  export DEVICE="Redmi Note 5 Pro / AI"
  export CODENAME="Whyred"
  AK3_DIR=$KERNEL_DIR/ak3-whyred/
  export KERNEL_DEFCONFIG=mystic-whyred-newcam_defconfig
  export CAM_BLOB="NewCam"
# if tulip
elif [[ "$@" =~ "tulipoldcam" ]]; then
  export DEVICE="Redmi Note 6 Pro"
  export CODENAME="Tulip"
  AK3_DIR=$KERNEL_DIR/ak3-tulip/
  export KERNEL_DEFCONFIG=mystic-tulip-oldcam_defconfig
  export CAM_BLOB="OldCam"
elif [[ "$@" =~ "tulipnewcam" ]]; then
  export DEVICE="Redmi Note 6 Pro"
  export CODENAME="Tulip"
  AK3_DIR=$KERNEL_DIR/ak3-tulip/
  export KERNEL_DEFCONFIG=mystic-tulip-newcam_defconfig
  export CAM_BLOB="NewCam"
# if lavender
elif [[ "$@" =~ "lavenderoldcam" ]]; then
  export DEVICE="Redmi Note 7"
  export CODENAME="Lavender"
  AK3_DIR=$KERNEL_DIR/ak3-lavender/
  export KERNEL_DEFCONFIG=mystic-lavender-oldcam_defconfig
  export CAM_BLOB="OldCam"
elif [[ "$@" =~ "lavendernewcam" ]]; then
  export DEVICE="Redmi Note 7"
  export CODENAME="Lavender"
  AK3_DIR=$KERNEL_DIR/ak3-lavender/
  export KERNEL_DEFCONFIG=mystic-lavender-newcam_defconfig
  export CAM_BLOB="NewCam"
# if a26x
elif [[ "$@" =~ "a26xoldcam" ]]; then
  export DEVICE="Mi A2/6X"
  export CODENAME="A26X"
  export REAL_CODENAME="Jasmine/Wayne"
  AK3_DIR=$KERNEL_DIR/ak3-a26x/
  export KERNEL_DEFCONFIG=mystic-a26x-oldcam_defconfig
  export CAM_BLOB="OldCam"
elif [[ "$@" =~ "a26xnewcam" ]]; then
  export DEVICE="Mi A2/6X"
  export CODENAME="A26X"
  export REAL_CODENAME="Jasmine/Wayne"
  AK3_DIR=$KERNEL_DIR/ak3-a26x/
  export KERNEL_DEFCONFIG=mystic-a26x-newcam_defconfig
  export CAM_BLOB="NewCam"
elif [[ "$@" =~ "a26xtencam" ]]; then
  export DEVICE="Mi A2/6X"
  export CODENAME="A26X"
  export REAL_CODENAME="Jasmine/Wayne"
  AK3_DIR=$KERNEL_DIR/ak3-a26x/
  export KERNEL_DEFCONFIG=mystic-a26x-tencam_defconfig
  export CAM_BLOB="TenCam"
# if whyred OverClock
elif [[ "$@" =~ "ocwhyredold" ]]; then
  git apply oc.patch
  export DEVICE="Redmi Note 5 Pro / AI"
  export CODENAME="Whyred"
  export LOCALVERSION=-OC
  AK3_DIR=$KERNEL_DIR/ak3-whyred/
  export KERNEL_DEFCONFIG=mystic-whyred-oldcam_defconfig
  export CAM_BLOB="OldCam-OverClock"
elif [[ "$@" =~ "ocwhyrednew" ]]; then
  export DEVICE="Redmi Note 5 Pro / AI"
  export CODENAME="Whyred"
  export LOCALVERSION=-OC
  AK3_DIR=$KERNEL_DIR/ak3-whyred/
  export KERNEL_DEFCONFIG=mystic-whyred-newcam_defconfig
  export CAM_BLOB="NewCam-OverClock"
# if tulip OverClock
elif [[ "$@" =~ "octulipold" ]]; then
  export DEVICE="Redmi Note 6 Pro"
  export CODENAME="Tulip"
  export LOCALVERSION=-OC
  AK3_DIR=$KERNEL_DIR/ak3-tulip/
  export KERNEL_DEFCONFIG=mystic-tulip-oldcam_defconfig
  export CAM_BLOB="OldCam-OverClock"
elif [[ "$@" =~ "octulipnew" ]]; then
  export DEVICE="Redmi Note 6 Pro"
  export CODENAME="Tulip"
  export LOCALVERSION=-OC
  AK3_DIR=$KERNEL_DIR/ak3-tulip/
  export KERNEL_DEFCONFIG=mystic-tulip-newcam_defconfig
  export CAM_BLOB="NewCam-OverClock"
fi

# Start Compile
make -s -C "$(pwd)" O=out $KERNEL_DEFCONFIG
make -C "$(pwd)" O=out \
        -j"$(nproc --all)" \
        CC=clang \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# If build error
if ! [ $? -eq 0 ]; then
  sendInfo "<b>Build Kernel for <code>$DEVICE</code> <code>$CAM_BLOB</code> failed, please fix...!</b>"
  exit 1
fi

# Make zip
cd $AK3_DIR
cp $KERNEL_IMG $AK3_DIR/
zip -r9 Mystic-$CODENAME-EAS_$CAM_BLOB-$ZIP_DATE.zip *
cd $KERNEL_DIR

sendKernel

rm -rf out/arch/arm64/boot/
rm -rf out/.version
rm -rf $AK3_DIR/*.zip
