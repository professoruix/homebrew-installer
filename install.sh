#!/bin/bash

function install_on_mac() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Tapping the repository and installing the script..."
    brew tap professoruix/installer
    brew install installer_script
}

function install_on_linux() {
    REPO_DIR="$HOME/uixlabs_installer"
    GIT_REPO_URL="https://github.com/professoruix/installer.git"

    # Check if Git is installed, if not install it
    if ! command -v git &>/dev/null; then
        echo "Git not found! Installing..."
        sudo apt-get update
        sudo apt-get install -y git
    fi

    # Clone the repository
    if [ ! -d "$REPO_DIR" ]; then
        git clone "$GIT_REPO_URL" "$REPO_DIR" || { echo "Cloning failed! Exiting..."; exit 1; }
        echo "Repository cloned into $REPO_DIR"
    else
        echo "$REPO_DIR already exists. Updating repository..."
        git -C "$REPO_DIR" pull || { echo "Updating failed! Exiting..."; exit 1; }
    fi

    # Change to the repository directory
    cd "$REPO_DIR" || { echo "Changing directory failed! Exiting..."; exit 1; }

    # Check if the installer script exists and is executable
    if [ ! -x installer.sh ]; then
        echo "Installer script not found or not executable. Making it executable..."
        chmod +x installer.sh || { echo "Failed to change script permissions. Exiting..."; exit 1; }
    fi

    # Run the installer script
    echo "Running the installer script..."
    ./installer.sh || { echo "Running installer script failed! Exiting..."; exit 1; }
}

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Proceeding with installation..."
    install_on_mac
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Proceeding with installation..."
    install_on_linux
else
    echo "Unsupported operating system."
    exit 1
fi

echo "Installation completed successfully."
