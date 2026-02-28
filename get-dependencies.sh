#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    glu       \
    libdecor  \
    sdl_mixer \
    sdl_net

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here
echo "Making stable build of Foobillard++..."
echo "---------------------------------------------------------------"
VERSION=3.42beta
echo $VERSION > ~/version
wget https://downloads.sourceforge.net/foobillardplus/foobillardplus-$VERSION.tar.gz
bsdtar -xvf foobillardplus-$VERSION.tar.gz

mkdir -p ./AppDir/bin
cd foobillardplus-3.42beta
sed -i 's|/opt/foobillardplus/bin/||' foobillardplus.desktop
sed -i 's|/opt/foobillardplus/||' foobillardplus.desktop
sed -e 's|freetype-config|pkg-config freetype2|g' -i src/Makefile.am
sed -e 's|inline float|float|g' -i src/vmath.*
sed -i '30i #include <stdlib.h>' src/vmath.c
sed -i '30i #include <math.h>' src/vmath.c
sed -i 's/abs(y)/fabsf(y)/g' src/vmath.c

aclocal --force
autoconf -f
autoheader -f
automake -a -c -f
./configure
make -j$(nproc)

mv -v foobillardplus.desktop ../AppDir
cp ./foobillardplus.png ../AppDir/.DirIcon
mv -v foobillardplus.png ../AppDir
mv -v src/foobillardplus ../AppDir/bin
mv -v data/* ../AppDir/bin
