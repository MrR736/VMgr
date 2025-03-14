#!/bin/bash
#Author:MrR736
#Created:2-28-2025
#HomePage: https://github.com/MrR736

HomePage="https://github.com/MrR736"

SCRIPT_NAME="vmgr"
SCRIPT_TEXT="Ventoy Manager Script"
SCRIPT_VERSION="1.0"

SCRIPT_BY="MrR736"

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
rm -rf /usr/local/share/doc/ventoy

mkdir -p "/usr/local/share/doc/ventoy" &> /dev/null

mv /usr/local/lib/ventoy/README /usr/local/share/doc/ventoy/

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/COPYING" -o /usr/local/share/doc/ventoy/copyright

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/LoopExBuild.txt" -o /usr/local/share/doc/ventoy/LoopExBuild

curl -sL "https://github.com/ventoy/Ventoy/raw/refs/heads/master/DOC/BuildVentoyFromSource.txt" -o /usr/local/share/doc/ventoy/BuildVentoyFromSource
}

DASKTOP_VENTOY() {
if [ "$(uname -m)" == "x86_64" ]; then
    cat > "/usr/local/share/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=/usr/local/lib/ventoy/VentoyGUI.x86_64
EOF
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    cat > "/usr/local/share/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=/usr/local/lib/ventoy/VentoyGUI.i386
EOF
elif [ "$(uname -m)" == "aarch64" ]; then
    cat > "/usr/local/share/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=/usr/local/lib/ventoy/VentoyGUI.aarch64
EOF
elif [ "$(uname -m)" == "mips64el" ]; then
    cat > "/usr/local/share/applications/ventoy.desktop" << EOF
[Desktop Entry]
Name=Ventoy
Type=Application
Categories=QT;GTK;Utility;System;
Terminal=false
Icon=ventoy
Exec=/usr/local/lib/ventoy/VentoyGUI.mips64el
EOF
else
    echo -e "\e[31mE: Unknown Type of Arch: $(uname -m)\e[0m" >&2
    exit 1
fi
}

SETUP_ventoy() {
tar -xJf "$DIR/ventoy.tar.xz" -C / &> /dev/null

mkdir -p "/usr/local/lib/ventoy" &> /dev/null

URL=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep '"browser_download_url":' | grep '.*\.tar.gz' | grep "linux" | cut -d '"' -f 4)

curl -sL "$URL" -o "/tmp/ventoy.tar.gz"

tar -xf "/tmp/ventoy.tar.gz" -C $TEMP_DIR &> /dev/null
cp -r $TEMP_DIR/*/* /usr/local/lib/ventoy/

rm -rf "$TEMP_DIR" "/tmp/ventoy.tar.gz" "/usr/local/bin/CreatePersistentImg.sh" "/usr/local/bin/ExtendPersistentImg.sh" "/usr/local/bin/VentoyPlugson.sh" "/usr/local/bin/VentoyWeb.sh" "/usr/local/bin/VentoyVlnk.sh" "/usr/local/bin/Ventoy2Disk.sh" "/usr/local/share/applications/ventoy.desktop"

DASKTOP_VENTOY

for files in /usr/local/lib/ventoy/CreatePersistentImg.sh /usr/local/lib/ventoy/ExtendPersistentImg.sh /usr/local/lib/ventoy/VentoyPlugson.sh /usr/local/lib/ventoy/VentoyWeb.sh /usr/local/lib/ventoy/VentoyVlnk.sh /usr/local/lib/ventoy/Ventoy2Disk.sh; do
    sed -i '2s|.*|cd /usr/local/lib/ventoy|' $files
done

chown -R root:root /usr/local/lib/ventoy
chmod -R 755 /usr/local/lib/ventoy

ln -s "/usr/local/lib/ventoy/CreatePersistentImg.sh" "/usr/local/bin/CreatePersistentImg.sh"

ln -s "/usr/local/lib/ventoy/ExtendPersistentImg.sh" "/usr/local/bin/ExtendPersistentImg.sh"

ln -s "/usr/local/lib/ventoy/VentoyPlugson.sh" "/usr/local/bin/VentoyPlugson.sh"

ln -s "/usr/local/lib/ventoy/VentoyWeb.sh" "/usr/local/bin/VentoyWeb.sh"

ln -s "/usr/local/lib/ventoy/VentoyVlnk.sh" "/usr/local/bin/VentoyVlnk.sh"

ln -s "/usr/local/lib/ventoy/Ventoy2Disk.sh" "/usr/local/bin/Ventoy2Disk.sh"

ln -s "/usr/local/lib/ventoy/ventoy/version" "/usr/local/lib/ventoy/version"

chmod 644 "/usr/local/share/applications/ventoy.desktop"

update-desktop-database

DOC_ventoy

chown -R root:root /usr/local/lib/ventoy
chmod -R 755 /usr/local/lib/ventoy
}

ventoy_remover() {
CHECK_ROOT

if [[ -f "/usr/local/lib/ventoy/VentoyGUI.x86_64" && -f "/usr/local/lib/ventoy/VentoyGUI.i386 && -f /usr/local/lib/ventoy/VentoyGUI.aarch64" && -f "/usr/local/lib/ventoy/VentoyGUI.mips64el" ]]; then
    echo "Ventoy is Not Installed, So Cancelling Removal." >&2
    exit 1
else
    echo "Remove Ventoy..."
    rm -rf "/usr/local/share/applications/ventoy.desktop" "/usr/local/lib/ventoy" "/usr/local/bin/CreatePersistentImg.sh" "/usr/local/bin/ExtendPersistentImg.sh" "/usr/local/bin/VentoyPlugson.sh" "/usr/local/bin/VentoyWeb.sh" "/usr/local/bin/VentoyVlnk.sh" "/usr/local/bin/Ventoy2Disk.sh" "/usr/local/share/doc/ventoy"

    for file in $(find /usr/local/share/icons/hicolor/* -name "ventoy.*"); do
        rm -rf "$file"
    done

    update-desktop-database

    echo "Ventoy has been Removed Successfully."
fi
}

CHECK_VERSION() {
    if [ ! -f "/usr/local/lib/ventoy/version" ]; then
        echo "Ventoy is Not Installed, So Cancelling Check Version." >&2
        exit 1
    fi

    VENTOY_VERSION=$(cat /usr/local/lib/ventoy/version)
    VENTOY_LATEST_VERSION=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

    echo "Version Of Ventoy: ${VENTOY_VERSION}
Latest Version Of Ventoy: ${VENTOY_LATEST_VERSION}"
}

ventoy_upgrader() {
CHECK_ROOT

if [[ -f "/usr/local/lib/ventoy/VentoyGUI.x86_64" && -f "/usr/local/lib/ventoy/VentoyGUI.i386 && -f /usr/local/lib/ventoy/VentoyGUI.aarch64" && -f "/usr/local/lib/ventoy/VentoyGUI.mips64el" ]]; then
    echo "Ventoy is Not Installed, So Cancelling Upgrade." >&2
    exit 1
fi

VENTOY_VERSION=$(cat /usr/local/lib/ventoy/version)
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

if [[ -f "/usr/local/lib/ventoy/VentoyGUI.x86_64" && -f "/usr/local/lib/ventoy/VentoyGUI.i386 && -f /usr/local/lib/ventoy/VentoyGUI.aarch64" && -f "/usr/local/lib/ventoy/VentoyGUI.mips64el" ]]; then
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
    if [[ -f "/usr/local/lib/ventoy/VentoyGUI.x86_64" && -f "/usr/local/lib/ventoy/VentoyGUI.i386 && -f /usr/local/lib/ventoy/VentoyGUI.aarch64" && -f "/usr/local/lib/ventoy/VentoyGUI.mips64el" ]]; then
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
        if [[ -f "/usr/local/lib/ventoy/VentoyGUI.x86_64" && -f "/usr/local/lib/ventoy/VentoyGUI.i386 && -f /usr/local/lib/ventoy/VentoyGUI.aarch64" && -f "/usr/local/lib/ventoy/VentoyGUI.mips64el" ]]; then
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
