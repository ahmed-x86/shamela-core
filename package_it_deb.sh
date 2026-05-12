#!/bin/bash

# Colors for formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' 

echo -e "${BLUE}Starting the Debian (.deb) packaging for Al-Shamela Library...${NC}"

# Check for required packaging tools
if ! command -v dpkg-deb &> /dev/null || ! command -v fakeroot &> /dev/null; then
    echo -e "${RED}Error: 'dpkg-deb' or 'fakeroot' is not installed.${NC}"
    echo -e "On Arch Linux, install them using: ${GREEN}sudo pacman -S dpkg fakeroot${NC}"
    exit 1
fi

REPO_URL="https://raw.githubusercontent.com/ahmed-x86/shamela-core/refs/heads/main/"

download_if_missing() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "${BLUE}$file not found locally. Downloading...${NC}"
        curl -sO "${REPO_URL}${file}"
    fi
}

# Download the program file if it doesn't exist
URL="https://archive.org/download/shamela_download/shamela-linux-1447.11.tar.xz"
FILE_NAME="shamela-linux.tar.xz"
VERSION="1447.11"
ARCH="amd64"
DEB_PKG_NAME="shamela-linux_${VERSION}_${ARCH}"

if [ ! -f "$FILE_NAME" ]; then
    echo -e "${BLUE}Downloading the program file...${NC}"
    wget -O "$FILE_NAME" "$URL"
else
    echo -e "${GREEN}Program file already exists, skipping download.${NC}"
fi

# Ensure required assets are downloaded
download_if_missing "launch.sh"
download_if_missing "shamela.desktop"
download_if_missing "shamela.png"

# Create Debian package directory structure
echo -e "${BLUE}Creating Debian package structure...${NC}"
BUILD_DIR="./${DEB_PKG_NAME}"

mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/opt/shamela"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/applications"
mkdir -p "${BUILD_DIR}/usr/share/icons/hicolor/256x256/apps"

# 1. Extract and move program files
echo -e "${BLUE}Extracting files...${NC}"
mkdir -p ./shamela_temp
tar -xf "$FILE_NAME" -C ./shamela_temp
cp -r ./shamela_temp/* "${BUILD_DIR}/opt/shamela/"
rm -rf ./shamela_temp

# 2. Setup launch script and symlink
cp launch.sh "${BUILD_DIR}/opt/shamela/launch.sh"
chmod +x "${BUILD_DIR}/opt/shamela/launch.sh"
ln -sf /opt/shamela/launch.sh "${BUILD_DIR}/usr/bin/shamela"

# 3. Setup Desktop entry and Icon
cp shamela.desktop "${BUILD_DIR}/usr/share/applications/"
if [ -f "shamela.png" ]; then
    cp shamela.png "${BUILD_DIR}/usr/share/icons/hicolor/256x256/apps/shamela.png"
fi

# 4. Create DEBIAN/control file
echo -e "${BLUE}Generating control file...${NC}"
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: shamela
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: libselinux1, bash
Maintainer: ahmed-x86
Description: Al-Shamela Library for Linux
 A comprehensive digital library application for Linux,
 packaged with custom launcher and dependencies.
EOF

# Set proper permissions for the deb package contents
echo -e "${BLUE}Setting proper permissions...${NC}"
chmod -R 755 "${BUILD_DIR}/DEBIAN"
chmod 644 "${BUILD_DIR}/DEBIAN/control"
find "${BUILD_DIR}/usr" -type d -exec chmod 755 {} \;
find "${BUILD_DIR}/usr/share" -type f -exec chmod 644 {} \;

# 5. Build the .deb package using fakeroot to ensure correct ownership
echo -e "${BLUE}Building the .deb package...${NC}"
fakeroot dpkg-deb --build "${BUILD_DIR}"

# Cleanup build directory
rm -rf "${BUILD_DIR}"

echo -e "${GREEN}Success! The package ${DEB_PKG_NAME}.deb has been created in the current directory.${NC}"