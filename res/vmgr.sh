#!/bin/bash
#Author:MrR736
#Created:5-23-2026
#HomePage: https://github.com/MrR736

HomePage="https://github.com/MrR736"

SCRIPT_NAME="vmgr"
SCRIPT_TEXT="Ventoy Manager Script"
SCRIPT_VERSION="1.0"

SCRIPT_BY="MrR736"

USR_PATH="/usr/local"
SHARE_PATH="$USR_PATH/share"

for cmd in curl for readlink dirname if awk sed grep update-desktop-database ln rm update-mime-database echo mkdir tar; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: \e[0m$cmd Is Not Installed." >&2
        exit 1
    fi
done

CHECK_ROOT() {
if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: \e[0mYou have to Run as Superuser" >&2
    exit 1
fi
}

HELP_VENTOY() {
    echo "Usage: ${SCRIPT_NAME} <option> <command>

<Options>
  --help, -h        Display This Help Text And Exit
  --version, -V     Display Version Information And Exit
  -v                Check Version Of Ventoy And Exit
  install           Install Ventoy
  reinstall         Reinstall Ventoy
  remove            Remove Ventoy
  upgrade           Upgrade Ventoy

<Commands>
  -y                Yes

HomePage: <${HomePage}>"
}

Version_VENTOY() {
  echo "${SCRIPT_NAME} (${SCRIPT_TEXT}) ${SCRIPT_VERSION}

Written by ${SCRIPT_BY}"
  exit 1
}

DOC_ventoy() {
rm -rf $SHARE_PATH/doc/ventoy

mkdir -p "$SHARE_PATH/doc/ventoy" &> /dev/null

mv $USR_PATH/lib/ventoy/README $SHARE_PATH/doc/ventoy/

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/COPYING" -o $SHARE_PATH/doc/ventoy/copyright

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/LoopExBuild.txt" -o $SHARE_PATH/doc/ventoy/LoopExBuild

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/BuildVentoyFromSource.txt" -o $SHARE_PATH/doc/ventoy/BuildVentoyFromSource
}

DASKTOP_VENTOY() {
mkdir -p "$SHARE_PATH/applications" &> /dev/null

if [ "$(uname -m)" == "x86_64" ]; then
    cat > "$SHARE_PATH/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=$USR_PATH/lib/ventoy/VentoyGUI.x86_64
EOF
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    cat > "$SHARE_PATH/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=$USR_PATH/lib/ventoy/VentoyGUI.i386
EOF
elif [ "$(uname -m)" == "aarch64" ]; then
    cat > "$SHARE_PATH/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=$USR_PATH/lib/ventoy/VentoyGUI.aarch64
EOF
elif [ "$(uname -m)" == "mips64el" ]; then
    cat > "$SHARE_PATH/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=$USR_PATH/lib/ventoy/VentoyGUI.mips64el
EOF
else
    echo -e "\e[31mE: Unknown Type of Arch: $(uname -m)\e[0m" >&2
    exit 1
fi
}

SETUP_ventoy() {
mkdir -p "$USR_PATH/lib/ventoy" "$SHARE_PATH/icons/hicolor" &> /dev/null

tar -xJf "$DIR/ventoy.tar.xz" -C "$SHARE_PATH/icons/hicolor" &> /dev/null

URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep '"browser_download_url":' | grep '.*\.tar.gz' | grep "linux" | cut -d '"' -f 4)

curl -sL "$URL" -o "/tmp/ventoy.tar.gz"

tar -xf "/tmp/ventoy.tar.gz" -C $TEMP_DIR &> /dev/null
cp -r $TEMP_DIR/*/* $USR_PATH/lib/ventoy/

rm -rf "$TEMP_DIR" "/tmp/ventoy.tar.gz" "$USR_PATH/bin/CreatePersistentImg.sh" "$USR_PATH/bin/ExtendPersistentImg.sh" "$USR_PATH/bin/VentoyPlugson.sh" "$USR_PATH/bin/VentoyWeb.sh" "$USR_PATH/bin/VentoyVlnk.sh" "$USR_PATH/bin/Ventoy2Disk.sh" "$SHARE_PATH/applications/ventoy.desktop"

DASKTOP_VENTOY

for files in $USR_PATH/lib/ventoy/CreatePersistentImg.sh $USR_PATH/lib/ventoy/ExtendPersistentImg.sh $USR_PATH/lib/ventoy/VentoyPlugson.sh $USR_PATH/lib/ventoy/VentoyWeb.sh $USR_PATH/lib/ventoy/VentoyVlnk.sh $USR_PATH/lib/ventoy/Ventoy2Disk.sh; do
    sed -i '2s|.*|cd $USR_PATH/lib/ventoy|' $files
done

chown -R root:root $USR_PATH/lib/ventoy
chmod -R 755 $USR_PATH/lib/ventoy

ln -s "$USR_PATH/lib/ventoy/CreatePersistentImg.sh" "$USR_PATH/bin/CreatePersistentImg.sh"

ln -s "$USR_PATH/lib/ventoy/ExtendPersistentImg.sh" "$USR_PATH/bin/ExtendPersistentImg.sh"

ln -s "$USR_PATH/lib/ventoy/VentoyPlugson.sh" "$USR_PATH/bin/VentoyPlugson.sh"

ln -s "$USR_PATH/lib/ventoy/VentoyWeb.sh" "$USR_PATH/bin/VentoyWeb.sh"

ln -s "$USR_PATH/lib/ventoy/VentoyVlnk.sh" "$USR_PATH/bin/VentoyVlnk.sh"

ln -s "$USR_PATH/lib/ventoy/Ventoy2Disk.sh" "$USR_PATH/bin/Ventoy2Disk.sh"

ln -s "$USR_PATH/lib/ventoy/ventoy/version" "$USR_PATH/lib/ventoy/version"

chmod 644 "$SHARE_PATH/applications/ventoy.desktop"

update-desktop-database

DOC_ventoy

chown -R root:root $USR_PATH/lib/ventoy
chmod -R 755 $USR_PATH/lib/ventoy
}

ventoy_remover() {
CHECK_ROOT

if [[ -f "$USR_PATH/lib/ventoy/VentoyGUI.x86_64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.i386 && -f $USR_PATH/lib/ventoy/VentoyGUI.aarch64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.mips64el" ]]; then
    echo "Ventoy is Not Installed, So Cancelling Removal." >&2
    exit 1
else
    echo "Remove Ventoy..."
    rm -rf "$SHARE_PATH/applications/ventoy.desktop" "$USR_PATH/lib/ventoy" "$USR_PATH/bin/CreatePersistentImg.sh" "$USR_PATH/bin/ExtendPersistentImg.sh" "$USR_PATH/bin/VentoyPlugson.sh" "$USR_PATH/bin/VentoyWeb.sh" "$USR_PATH/bin/VentoyVlnk.sh" "$USR_PATH/bin/Ventoy2Disk.sh" "$SHARE_PATH/doc/ventoy"

    for file in $(find $SHARE_PATH/icons/hicolor/* -name "ventoy.*"); do
        rm -rf "$file"
    done

    update-desktop-database

    echo "Ventoy has been Removed Successfully."
fi
}

CHECK_VERSION() {
    if [ ! -f "$USR_PATH/lib/ventoy/version" ]; then
        echo "Ventoy is Not Installed, So Cancelling Check Version." >&2
        exit 1
    fi

    VENTOY_VERSION=$(cat $USR_PATH/lib/ventoy/version)
    VENTOY_LATEST_VERSION=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

    echo "Version Of Ventoy: ${VENTOY_VERSION}
Latest Version Of Ventoy: ${VENTOY_LATEST_VERSION}"
}

ventoy_upgrader() {
CHECK_ROOT

if [[ -f "$USR_PATH/lib/ventoy/VentoyGUI.x86_64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.i386 && -f $USR_PATH/lib/ventoy/VentoyGUI.aarch64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.mips64el" ]]; then
    echo "Ventoy is Not Installed, So Cancelling Upgrade." >&2
    exit 1
fi

VENTOY_VERSION=$(cat $USR_PATH/lib/ventoy/version)
VENTOY_LATEST_VERSION=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

if [[ "$VENTOY_LATEST_VERSION" > "$VENTOY_VERSION" ]]; then
    echo "Upgrade Ventoy..."
else
    echo "You Are Already Using The Latest Version Of Ventoy: $VENTOY_VERSION"
    exit 1
fi

TEMP_DIR=$(mktemp -d /tmp/ventoy.XXXXXXXXXX)

SETUP_ventoy

echo "Ventoy has been Upgrade successfully."
}



ventoy_installer() {
CHECK_ROOT

echo "Install Ventoy..."

if [[ -f "$USR_PATH/lib/ventoy/VentoyGUI.x86_64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.i386 && -f $USR_PATH/lib/ventoy/VentoyGUI.aarch64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.mips64el" ]]; then
    echo "Ventoy is Already Installed, so Cancelling Installation."
    exit 1
fi

TEMP_DIR=$(mktemp -d /tmp/ventoy.XXXXXXXXXX)

SETUP_ventoy

echo "Ventoy has been Install successfully."
}

ventoy_install() {
read -p "Do You Want Install? <YES=y/No=n> " InstallFormat

if [[ "$InstallFormat" == "y" ]]; then
    ventoy_installer
else
    echo "Abort."
    exit 1
fi
exit 1
}

ventoy_upgrade() {
read -p "Do You Want Upgrade? <YES=y/No=n> " InstallFormat

if [[ "$InstallFormat" == "y" ]]; then
    ventoy_upgrader
else
    echo "Abort."
    exit 1
fi
exit 1
}

ventoy_remove() {
read -p "Do You Want Remove? <YES=y/No=n> " InstallFormat

if [[ "$InstallFormat" == "y" ]]; then
    ventoy_remover
else
    echo "Abort."
    exit 1
fi
exit 1
}

ventoy_reinstall() {
read -p "Do You Want Reinstall? <YES=y/No=n> " InstallFormat

if [[ "$InstallFormat" == "y" ]]; then
    CHECK_ROOT
    if [[ -f "$USR_PATH/lib/ventoy/VentoyGUI.x86_64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.i386 && -f $USR_PATH/lib/ventoy/VentoyGUI.aarch64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.mips64el" ]]; then
        echo "Ventoy is Not Installed, So Cancelling Reinstall." >&2
        exit 1
    fi
    echo "Reinstall Ventoy..."
    ventoy_remover &> /dev/null
    ventoy_installer &> /dev/null
    echo "Ventoy has been Reinstall successfully."
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [ "${1,,}" == "install" ]; then
    if [ "${2}" == "-y" ]; then
        ventoy_installer
    else
        ventoy_install
    fi
elif [ "${1,,}" == "remove" ]; then
    if [ "${2}" == "-y" ]; then
        ventoy_remover
    else
        ventoy_remove
    fi
elif [ "${1,,}" == "upgrade" ]; then
    if [ "${2}" == "-y" ]; then
        ventoy_upgrader
    else
        ventoy_upgrade
    fi
elif [ "${1,,}" == "reinstall" ]; then
    if [ "${2}" == "-y" ]; then
        CHECK_ROOT
        if [[ -f "$USR_PATH/lib/ventoy/VentoyGUI.x86_64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.i386 && -f $USR_PATH/lib/ventoy/VentoyGUI.aarch64" && -f "$USR_PATH/lib/ventoy/VentoyGUI.mips64el" ]]; then
            echo "Ventoy is Not Installed, So Cancelling Reinstall." >&2
            exit 1
        fi
        echo "Reinstall Ventoy..."
        ventoy_remover &> /dev/null
        ventoy_installer &> /dev/null
        echo "Ventoy has been Reinstall successfully."
    else
        ventoy_reinstall
    fi
elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
    HELP_VENTOY
    exit 1
elif [[ "$1" == "--version" || "$1" == "-V" ]]; then
    Version_VENTOY
    exit 1
elif [ "$1" == "-v" ]; then
    CHECK_VERSION
    exit 1
else
    echo -e "Usage: ${SCRIPT_NAME} <option> <command>\nTry '${SCRIPT_NAME} --help' for more information."
    exit 1
fi
