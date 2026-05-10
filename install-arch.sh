#!/bin/bash

# Colors for formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting the installation of Al-Shamela Library on Arch Linux...${NC}"

# 1. Check for libselinux and install via AUR
install_libselinux() {
    if pacman -Qi libselinux &> /dev/null; then
        echo -e "${GREEN}libselinux is already installed.${NC}"
    else
        echo -e "${BLUE}Attempting to install libselinux from AUR...${NC}"
        if command -v yay &> /dev/null; then
            yay -S --noconfirm libselinux
        elif command -v paru &> /dev/null; then
            paru -S --noconfirm libselinux
        else
            echo -e "${BLUE}Neither yay nor paru found, installing manually from Git...${NC}"
            git clone https://aur.archlinux.org/libselinux.git
            cd libselinux && makepkg -si --noconfirm
            cd .. && rm -rf libselinux
        fi
    fi
}

install_libselinux

# 2. Download the file if it doesn't exist
URL="https://archive.org/download/shamela_download/shamela-linux-1447.11.tar.xz"
FILE_NAME="shamela-linux.tar.xz"

if [ ! -f "$FILE_NAME" ]; then
    echo -e "${BLUE}Downloading the program file...${NC}"
    wget -O "$FILE_NAME" "$URL"
else
    echo -e "${GREEN}Program file already exists, skipping download.${NC}"
fi

# 3. Extract and prepare directories
echo -e "${BLUE}Extracting and moving files to /opt/shamela...${NC}"
mkdir -p ./shamela_temp
tar -xf "$FILE_NAME" -C ./shamela_temp

sudo mkdir -p /opt/shamela
# Move the extracted contents to the destination
sudo cp -r ./shamela_temp/* /opt/shamela/
rm -rf ./shamela_temp

# 4. Install launch.sh script
echo -e "${BLUE}Setting up the launch script...${NC}"
sudo cp launch.sh /opt/shamela/launch.sh
sudo chmod +x /opt/shamela/launch.sh

# Create a symlink to run the 'shamela' command from anywhere
sudo ln -sf /opt/shamela/launch.sh /usr/bin/shamela

# 5. Install Desktop entry and Icon
echo -e "${BLUE}Installing desktop shortcut...${NC}"
# Copy the icon to the system icons directory if it exists
if [ -f "shamela.png" ]; then
    sudo cp shamela.png /usr/share/icons/hicolor/256x256/apps/shamela.png
fi

sudo cp shamela.desktop /usr/share/applications/

echo -e "${GREEN}Installation completed successfully! You can now run the program by typing 'shamela' in the terminal or via the applications menu.${NC}"