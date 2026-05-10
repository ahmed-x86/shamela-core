#!/bin/bash

# Colors for formatting
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting the uninstallation of Al-Shamela Library from the system...${NC}"

# 1. Remove main files from /opt
if [ -d "/opt/shamela" ]; then
    echo -e "${BLUE}Removing program files from /opt/shamela...${NC}"
    sudo rm -rf /opt/shamela
else
    echo -e "${RED}Directory /opt/shamela does not exist.${NC}"
fi

# 2. Remove the Symlink
if [ -L "/usr/bin/shamela" ]; then
    echo -e "${BLUE}Removing symlink from /usr/bin...${NC}"
    sudo rm /usr/bin/shamela
fi

# 3. Remove Desktop entry
if [ -f "/usr/share/applications/shamela.desktop" ]; then
    echo -e "${BLUE}Removing desktop entry...${NC}"
    sudo rm /usr/share/applications/shamela.desktop
fi

# 4. Remove the Icon
if [ -f "/usr/share/icons/hicolor/256x256/apps/shamela.png" ]; then
    echo -e "${BLUE}Removing icon from the system...${NC}"
    sudo rm /usr/share/icons/hicolor/256x256/apps/shamela.png
fi

# Dependency Warning
echo -e "${RED}Note: 'libselinux' was not removed as it might be required by other applications.${NC}"
echo -e "${RED}If you wish to remove it manually, run: sudo pacman -Rs libselinux${NC}"

echo -e "${RED}Al-Shamela Library has been successfully uninstalled.${NC}"