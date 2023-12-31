#!/bin/bash -i

version="1.0.0"

function show_help {
    echo "Usage: ${0##*/} [OPTION]..."
    echo "Set up my environment, including Docker, Python3, and Flask."
    echo "Optionally executes a Python script after setup."
    echo ""
    echo "Options:"
    echo "  --version           display the version of the script and exit"
    echo "  --help              display this help and exit"
}

# Process command-line options
while :; do
    case $1 in
        --help)
            show_help
            exit
            ;;
        --version)
            echo "Installer script version $version"
            exit
            ;;
        *)  # No more options
            break
            ;;
    esac
    shift
done

# Start the logging
echo "Starting script..." >> /tmp/my_script.log

# Separate actions based on OS type
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Actions for macOS
    echo "Running on macOS..."

    if [[ -e /Applications/Docker.app ]]; then
        open /Applications/Docker.app
        echo "Waiting for Docker to start..."
        sleep 5
    else
        echo "Docker Desktop not found. Consider installing it for the Docker daemon."
    fi

    # Explicitly set PATH for Homebrew on macOS
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

    # Update PATH for Homebrew on macOS
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        echo "Docker CLI not found! Installing..."
        brew install docker
        echo "Note: Only Docker CLI is installed. You will need Docker Desktop for the daemon."
    else
        echo "Docker CLI is already installed!"
    fi

    # Install Python3 if not present
    if ! command -v python3 &> /dev/null; then
        echo "Python3 not found! Installing..."
        brew install python3
    else
        echo "Python3 is already installed!"
    fi

    # Set the app directory path for macOS
    APP_DIR=/opt/homebrew/Library/Taps/professoruix/homebrew-installer

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Actions for Linux
    echo "Running on Linux..."

    # Check for Docker and install if it's not present
    if ! command -v docker &> /dev/null; then
        echo "Docker not found! Installing..."
        # Update the apt package index and install packages to allow apt to use a repository over HTTPS
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

        # Add Docker’s official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Set up the stable repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # Manage Docker as a non-root user
        sudo groupadd docker
        sudo usermod -aG docker $USER
        newgrp docker

        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo "Docker is already installed!"
    fi

    # Check for Python3 and pip3 and install if they're not present
    if ! command -v python3 &> /dev/null; then
        echo "Python3 not found! Installing..."
        sudo apt-get update
        sudo apt-get install -y python3
    fi

    if ! command -v pip3 &> /dev/null; then
        echo "pip3 not found! Installing..."
        sudo apt-get install -y python3-pip
    else
        echo "Python3 and pip3 are already installed!"
    fi

    # Set the app directory path for Linux
    APP_DIR="$HOME/uixlabs_installer"  # Adjust this path as needed

else
    echo "Unsupported OS!"
    exit 1
fi

# Common actions for both macOS and Linux

# Install Flask
pip3 install Flask --user
pip3 install flask_cors --user

# Kill process running on port 7654 if any
lsof -t -i:7654 | xargs kill -9 2>/dev/null || true

# Navigate to the application directory and execute the script
#if [ -d "$APP_DIR" ]; then
#    cd "$APP_DIR" || { echo "Error: Failed to change directory to $APP_DIR"; exit 1; }
python3 app.py
#else
#    echo "Error: $APP_DIR does not exist."
#    exit 1
#fi

# End logging
echo "Finished script!" >> /tmp/my_script.log
