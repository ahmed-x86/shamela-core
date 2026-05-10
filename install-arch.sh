#!/bin/bash

# الألوان للتنسيق
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}بدء عملية تثبيت المكتبة الشاملة على Arch Linux...${NC}"

# 1. التحقق من وجود libselinux وتثبيته عبر AUR
install_libselinux() {
    if pacman -Qi libselinux &> /dev/null; then
        echo -e "${GREEN}libselinux مثبت بالفعل.${NC}"
    else
        echo -e "${BLUE}جاري محاولة تثبيت libselinux من الـ AUR...${NC}"
        if command -v yay &> /dev/null; then
            yay -S --noconfirm libselinux
        elif command -v paru &> /dev/null; then
            paru -S --noconfirm libselinux
        else
            echo -e "${BLUE}لم يتم العثور على yay أو paru، جاري التثبيت يدوياً من Git...${NC}"
            git clone https://aur.archlinux.org/libselinux.git
            cd libselinux && makepkg -si --noconfirm
            cd .. && rm -rf libselinux
        fi
    fi
}

install_libselinux

# 2. تحميل الملف إذا لم يكن موجوداً
URL="https://archive.org/download/shamela_download/shamela-linux-1447.11.tar.xz"
FILE_NAME="shamela-linux.tar.xz"

if [ ! -f "$FILE_NAME" ]; then
    echo -e "${BLUE}جاري تحميل ملف البرنامج...${NC}"
    wget -O "$FILE_NAME" "$URL"
else
    echo -e "${GREEN}ملف البرنامج موجود مسبقاً، سيتم تخطي التحميل.${NC}"
fi

# 3. فك الضغط وتجهيز المجلدات
echo -e "${BLUE}جاري فك الضغط ونقل الملفات إلى /opt/shamela...${NC}"
mkdir -p ./shamela_temp
tar -xf "$FILE_NAME" -C ./shamela_temp

sudo mkdir -p /opt/shamela
# نفترض أن الملفات داخل الأرشيف تخرج مباشرة أو داخل مجلد
sudo cp -r ./shamela_temp/* /opt/shamela/
rm -rf ./shamela_temp

# 4. تثبيت ملف التشغيل launch.sh
echo -e "${BLUE}إعداد سكربت التشغيل...${NC}"
sudo cp launch.sh /opt/shamela/launch.sh
sudo chmod +x /opt/shamela/launch.sh

# عمل رابط رمزي ليعمل أمر shamela من أي مكان
sudo ln -sf /opt/shamela/launch.sh /usr/bin/shamela

# 5. تثبيت ملف الـ Desktop والأيقونة
echo -e "${BLUE}تثبيت اختصار سطح المكتب...${NC}"
# إذا كانت الأيقونة موجودة في المجلد يفضل نسخها لمجلد الأيقونات العام
if [ -f "shamela.png" ]; then
    sudo cp shamela.png /usr/share/icons/hicolor/256x256/apps/shamela.png
fi

sudo cp shamela.desktop /usr/share/applications/

echo -e "${GREEN}تم التثبيت بنجاح! يمكنك الآن تشغيل البرنامج بكتابة 'shamela' في الطرفية أو عبر قائمة التطبيقات.${NC}"