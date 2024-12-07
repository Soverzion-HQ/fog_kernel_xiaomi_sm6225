export TZ='Asia/Jakarta'
BUILDDATE=$(date +%Y%m%d)
NAME=Rebellion
# BUILDTIME=$(date +%H%M)

# Set variable
export KBUILD_BUILD_USER=Drenzzz
export KBUILD_BUILD_HOST=Soverzion

    # Build
    # Prepare
    make -j$(nproc --all) O=out ARCH=arm64 CC=$(pwd)/clang/bin/clang CROSS_COMPILE=aarch64-linux-gnu- CLANG_TRIPLE=aarch64-linux-gnu- LLVM_IAS=1 vendor/fog-perf_defconfig  2>&1 | tee build1.log

    # Execute
    make -j$(nproc --all) O=out ARCH=arm64 CC=$(pwd)/clang/bin/clang CROSS_COMPILE=aarch64-linux-gnu- CLANG_TRIPLE=aarch64-linux-gnu- LLVM_IAS=1  2>&1 | tee build2.log

    # Package
    git clone --depth=1 https://github.com/ardia-kun/AnyKernel3-680 -b ksu AnyKernel3
    cp -R out/arch/arm64/boot/Image.gz AnyKernel3/Image.gz
    # Zip it and upload it
    cd AnyKernel3
    zip -r9 $NAME-Kernel-"$BUILDDATE" . -x ".git*" -x "README.md" -x "*.zip"
    wget https://raw.githubusercontent.com/drenzzz/GoFile-Upload/master/upload.sh
    chmod +x upload.sh
    ./upload.sh $NAME-Kernel-"$BUILDDATE".zip
    # finish
    cd ..
    rm -rf clang-llvm/ AnyKernel3/
    echo "Build finished"
    cat build1.log | nc termbin.com 9999
    cat build2.log | nc termbin.com 9999