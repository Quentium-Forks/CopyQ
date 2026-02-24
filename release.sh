#!/bin/bash
VERSION=13.0.3
DIR=copyq-$VERSION
ARCH=$(uname -m)
ARCH_DPKG=$(dpkg --print-architecture)
export VERSION=$VERSION

# cleanup
rm -rf build release translations/*.qm shared/rpm/BUILD shared/rpm/BUILDROOT shared/rpm/*RPMS shared/rpm/SOURCES debug*.list elfbins.list

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

# build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr $EXTRA_FLAGS
cmake --build build -j $(nproc)
strip -s build/copyq

# assets
mkdir -p release/$DIR
cp -r src plugins qxt shared translations CMakeLists.txt debian AUTHORS CHANGES.md HACKING README.md release/$DIR

# translations
export QT_SELECT=qt6
# Expand PATH to find lupdate & lrelease
export PATH="/usr/lib/$QT_SELECT/bin:$PATH"
lupdate src/ plugins/*/*.{cpp,h,ui} -ts translations/*.ts
lrelease translations/*.ts
mkdir -p release/$DIR/copyq/translations
cp translations/*.qm release/$DIR/copyq/translations

# Change architecture
sed -i "s/^Architecture:\s\+.*$/Architecture: $ARCH_DPKG/g" release/$DIR/debian/control

# tarball
tar -czf release/$DIR.tar.gz -C release $DIR

# appimagetool
wget -qc https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-$ARCH.AppImage" | head -n 1 | cut -d '"' -f 2) -O appimagetool-$ARCH.AppImage
chmod +x appimagetool-$ARCH.AppImage

# appimage
DESTDIR=../release/$DIR cmake --build build --target install -j $(nproc)
./appimagetool-$ARCH.AppImage -s deploy release/$DIR/usr/share/applications/com.github.hluk.copyq.desktop
./appimagetool-$ARCH.AppImage release/$DIR
mv CopyQ-$VERSION-$ARCH.AppImage release

rm appimagetool-$ARCH.AppImage

# debian package
cd release/$DIR
# Export CMake prefix path for debuild using aqtinstall
if [ -z "$QT_PLUGIN_PATH" ]; then
    QT_ROOT=$(dirname "$QT_PLUGIN_PATH")
    export CMAKE_PREFIX_PATH="$QT_ROOT/lib/cmake"
fi
dh_make --createorig --indep --yes
debuild --preserve-envvar=CMAKE_PREFIX_PATH \
    --preserve-envvar=QT_PLUGIN_PATH \
    --preserve-envvar=LD_LIBRARY_PATH \
    --no-lintian -us -uc
cd ../..

# rpm package
mkdir -p shared/rpm/SOURCES
cp release/$DIR.tar.gz shared/rpm/SOURCES
# Change architecture
sed -i "s/^BuildArch:\s\+.*$/BuildArch:      $ARCH/g" shared/rpm/SPECS/copyq.spec
rpmbuild -bb --build-in-place --define "_topdir $(pwd)/shared/rpm" shared/rpm/SPECS/copyq.spec
mv shared/rpm/RPMS/$ARCH/copyq-$VERSION-1.$ARCH.rpm release/copyq-$VERSION.$ARCH.rpm
