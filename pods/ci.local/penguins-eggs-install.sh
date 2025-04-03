#!/usr/bin/env bash

set -x

##
#
#
function tarballsInstall {
    PENGUINS_EGGS_INSTALL_DIR="/opt/penguins-eggs/"
    PENGUINS_EGGS_TARBALLS="/ci/penguins-eggs_10.0.60-*-linux-x64.tar.gz"

    # Create /opt if not exists
    if [ ! -d "/opt" ]; then
        mkdir /opt
    fi

    # Rimozione di /opt/penguins-eggs se esiste
    if [ -d "$PENGUINS_EGGS_INSTALL_DIR" ]; then
        rm -rf "$PENGUINS_EGGS_INSTALL_DIR"
    fi

    # extract package
    tar -xf $PENGUINS_EGGS_TARBALLS
    if [ $? -ne 0 ]; then
        echo "Error: not possible extract $PENGUINS_EGGS_TARBALLS."
        exit 1
    fi

    mv eggs penguins-eggs
    $SUDO mv penguins-eggs /opt/

    # create link themes  grub/isolinux
    ln -sf "${PENGUINS_EGGS_INSTALL_DIR}addons/eggs/theme/livecd/isolinux.main.full.cfg" "${PENGUINS_EGGS_INSTALL_DIR}addons/eggs/theme/livecd/isolinux.main.cfg"
    ln -sf "${PENGUINS_EGGS_INSTALL_DIR}addons/eggs/theme/livecd/grub.main.full.cfg" "${PENGUINS_EGGS_INSTALL_DIR}addons/eggs/theme/livecd/grub.main.cfg"

    # Bash completions
    if [ -d "/usr/share/bash-completion/completions/" ]; then
        rm -f /usr/share/bash-completion/completions/eggs.bash
        ln -sf "${PENGUINS_EGGS_INSTALL_DIR}scripts/eggs.bash" /usr/share/bash-completion/completions/eggs.bash
    fi

    # Zsh completions
    if [ -d "/usr/share/zsh/functions/Completion/Zsh/" ]; then
        rm -f /usr/share/zsh/functions/Completion/Zsh/_eggs
        ln -sf "${PENGUINS_EGGS_INSTALL_DIR}scripts/_eggs" /usr/share/zsh/functions/Completion/Zsh/
    fi

    # Icons
    if [ -d "/usr/share/icons/" ]; then
        rm -f /usr/share/icons/eggs.png
        ln -sf "${PENGUINS_EGGS_INSTALL_DIR}assets/eggs.png" /usr/share/icons/eggs.png
    fi

    # Manual
    if [ -d "/usr/share/man/man1" ]; then
        rm -f /usr/share/man/man1/eggs.1.gz
        ln -sf "${PENGUINS_EGGS_INSTALL_DIR}manpages/doc/man/eggs.1.gz" /usr/share/man/man1/eggs.1.gz
    fi

    # Link binary
    rm -f /usr/bin/eggs
    ln -sf "${PENGUINS_EGGS_INSTALL_DIR}bin/eggs" /usr/bin/eggs
}

##
#
#
function debsInstall {
    PENGUINS_EGGS_DEB="/ci/penguins-eggs_10.0.60-*_amd64.deb"
    dpkg -i $PENGUINS_EGGS_DEB
    apt install -fy
}


##
# main
#
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "debian" ]]; then
        debsInstall
    elif [[ "$ID" == "devuan" ]]; then
        debsInstall
    elif [[ "$ID" == "ubuntu" ]]; then
        debsInstall
    else
        tarballsInstall
    fi
fi
