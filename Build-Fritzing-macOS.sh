#!/bin/bash

# Works for Fritzing 0.9.9, but not 0.9.10.
# Building 0.9.10 results in errors about quazip missing.

# https://github.com/fritzing/fritzing-app/wiki/1.-Building-Fritzing
# https://forum.fritzing.org/t/diary-of-a-mac-m1-build/12657

# Requires:
#   coreutils (for GNU tar)
#   qt 5 (at least 5.15)
#   Xcode

set -e

BUILDDIR='/tmp/fritzing'

# Check Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
  echo "Please install Xcode and retry."
  exit 1
fi

# Request password for sudo usage later.
# Easier than requesting mid-way through build, where it may not be noticed for a while.
echo "Requesting sudo access..."
sudo -v
echo

# Make and change to build directory
echo -e "Creating build directory: $BUILDDIR\n"
[ -d $BUILDDIR ] && rm -rf $BUILDDIR
mkdir "$BUILDDIR"
cd "$BUILDDIR"

# Clone Fritzing repositories
echo -e "Cloning fritzing repositories...\n"
git clone git@github.com:fritzing/fritzing-app.git
git clone git@github.com:fritzing/fritzing-parts.git

# Download dependencies
echo -e "\nDownloading dependencies...\n"
wget -q --show-progress https://github.com/libgit2/libgit2/releases/download/v0.28.5/libgit2-0.28.5.tar.gz
wget -q --show-progress https://boostorg.jfrog.io/artifactory/main/release/1.80.0/source/boost_1_80_0.tar.gz

# Extract dependencies
echo -e "\nExtracting dependencies..."
gtar -xzf libgit2-0.28.5.tar.gz --checkpoint=.10
mv libgit2-0.28.5 libgit2
gtar -xzf boost_1_80_0.tar.gz --checkpoint=.100

# Validate sudo again; next step takes a while.
sudo -v

# Build and install libgit2
echo -e "\n\nBuilding and installing libgit2...\n"
mkdir libgit2/build
cd libgit2/build
cmake -DBUILD_SHARED_LIBS=OFF ..
cmake --build .
sudo cmake --build . --target install

# Checkout main so we build the latest version
echo -e "\nChecking out fritzing-app main branch for latest version...\n"
cd "$BUILDDIR/fritzing-app"
git checkout main

# Fix libs/paths
echo -e "\nPatching libs paths..."
sed -e 's/\(\/System\/Library\/Frameworks\/.*\)/\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/MacOSX.platform\/Developer\/SDKs\/MacOSX.sdk\1.tbd/g' \
  -e 's/\(LIBS += \/usr\/lib\/libz.dylib\)/#\1/g' \
  -e 's/#\(QMAKE_MAC_SDK = \).*/\1macosx12.3/g' \
  phoenix.pro > phoenix.pro.fixup
sed 's/\(\/System\/Library\/Frameworks\/.*\)/\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/MacOSX.platform\/Developer\/SDKs\/MacOSX.sdk\1.tbd/g' \
  pri/libgit2detect.pri > pri/libgit2detect.pri.fixup
mv phoenix.pro.fixup phoenix.pro
mv pri/libgit2detect.pri.fixup pri/libgit2detect.pri

# No open DMG
sed -e 's/echo ">> launch Fritzing"//g' \
  -e 's/cd "\$deploydir"//g' \
  -e 's/open Fritzing.dmg//g' \
  tools/deploy_fritzing_mac.sh > tools/deploy_fritzing_mac.sh.fixup
mv tools/deploy_fritzing_mac.sh.fixup tools/deploy_fritzing_mac.sh
chmod +x tools/deploy_fritzing_mac.sh

# Run deploy script
echo -e "\nBuilding fritzing...\n"
cd tools
./deploy_fritzing_mac.sh

# Copy DMG to downloads
cd "$BUILDDIR"
mv deploy-app/Fritzing.dmg /home/$USER/Downloads/

echo -e "\nDone!\nHere is your DMG: /home/$USER/Downloads/Fritzing.dmg"

echo -e "\nRemoving build directory: $BUILDDIR"
rm -rf "$BUILDDIR"
