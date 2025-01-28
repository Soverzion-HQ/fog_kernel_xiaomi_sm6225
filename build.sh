export TZ='Asia/Jakarta'
BUILDDATE=$(date +%Y%m%d)
NAME=Rebellion
# BUILDTIME=$(date +%H%M)

# Set variable
export KBUILD_BUILD_USER=Drenzzz
export KBUILD_BUILD_HOST=Soverzion

# Terminal colors (To simulate log levels)
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Script variables
SCRIPT_DIR=$(pwd)/build
TC_DIR="$SCRIPT_DIR"/clang-20
AK_DIR="$SCRIPT_DIR"/AnyKernel3
MAKE_ARGS="O=out ARCH=arm64 CC=clang LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-"

# Start logging
BUILD_START=$(date)
echo "======================== BUILD STARTED: $BUILD_START ========================"
# Clone aosp clang from its repo
echo "Cloning clang-20 into $TC_DIR"
git clone --depth=1 https://gitea.com/drenzzz/clang-20 $TC_DIR
# Clone AnyKernel3 (TODO: Fix this for GKI and garnet)
echo "Cloning AnyKernel3 into $AK_DIR"
git clone --depth=1 https://github.com/drenzzz/AnyKernel3 -b fog $AK_DIR
# Export the PATH variable
echo "Exporting PATH variable"
export PATH="$TC_DIR/bin:$PATH"
# Build defconfig
echo "Running make for defconfig"
make -j"$(nproc --all)" $MAKE_ARGS vendor/fog-perf_defconfig  2>&1 | tee build1.log
if [ $? -ne 0 ]; then
    echo -e "Build Script: ${RED}Failed to generate defconfig.${NOCOLOR}"
    exit 1
fi
# Build kernel
echo "Compiling the kernel"
make -j"$(nproc --all)" $MAKE_ARGS 2>&1 | tee build2.log
if [ $? -ne 0 ]; then
    echo -e "Build Script: ${RED}Kernel compilation failed. Check $LOG_FILE for details.${NOCOLOR}"
    exit 1
fi
# Zip the kernel and pack it into an AnyKernel3 zip
FILE="$(pwd)/out/arch/arm64/boot/Image.gz"
BUILD_TIME=$(date +"%d%m%Y-%H%M")
KERNEL_NAME="Rebellion-"${BUILD_TIME}"-fog"
FILE_OUT=""$AK_DIR"/"$KERNEL_NAME".zip"
if [ -f "$FILE" ]; then
    echo -e "Build Script: ${GREEN}The kernel has successfully been compiled.${NOCOLOR}"
    rm -rf $AK_DIR/Image.gz $AK_DIR/*.zip $AK_DIR/*.ko
    cp $FILE $AK_DIR
    cd $AK_DIR
    zip -r9 "$KERNEL_NAME".zip ./
    echo "Build Script: The kernel has been zipped and can be found in $FILE_OUT."
    BUILD_END=$(date)
    cat build1.log | nc termbin.com 9999
    cat build2.log | nc termbin.com 9999

    wget https://raw.githubusercontent.com/drenzzz/GoFile-Upload/master/upload.sh
    chmod +x upload.sh
    ./upload.sh "$AK_DIR"/"$KERNEL_NAME".zip
    echo "======================== BUILD COMPLETED: $BUILD_END ========================"
    exit 0
else
    echo -e "Build Script: ${RED}The kernel failed to compile. Check your compiler output for build errors.${NOCOLOR}"
    exit 1
fi
