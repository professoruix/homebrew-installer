#!/bin/bash

function install_on_mac() {
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Tap your repository which contains the Homebrew formula and install
    brew tap professoruix/installer
    brew install installer_script
}

function install_on_linux() {
    # Check if curl and apt-transport-https are installed, install if not
    if ! command -v curl &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    if ! dpkg -s apt-transport-https &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
    fi

    # Add your repo or installation script here
    # For instance, if it's a Debian package repo, you might add the repo to the sources list,
    # then download and install the package using apt-get.

    # Since we're pretending this is a Debian package, let's simulate adding the repo and installing
    echo "deb [trusted=yes] https://repo.example.com/ any main" | sudo tee /etc/apt/sources.list.d/mysoftware.list
    sudo apt-get update
    sudo apt-get install -y mysoftware
}

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_on_mac
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_on_linux
else
    echo "Unsupported operating system."
    exit 1
fi
