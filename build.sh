#!/bin/bash

rm -rf build translations/*.qm

# Check if qca dependencies are installed
if dpkg -s libqca-qt6-dev > /dev/null 2>&1; then
    EXTRA_FLAGS="-DWITH_QCA_ENCRYPTION=ON"
else
    EXTRA_FLAGS="-DWITH_QCA_ENCRYPTION=OFF"
fi
# Check if kf6 dependencies are installed
if dpkg -s libkf6guiaddons-dev > /dev/null 2>&1; then
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_NATIVE_NOTIFICATIONS=ON"
else
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_NATIVE_NOTIFICATIONS=OFF"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug $EXTRA_FLAGS
cmake --build build -j $(nproc)

./build/copyq
