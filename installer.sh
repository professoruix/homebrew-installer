#!/bin/bash -i

# Explicitly set PATH for typical locations and Homebrew
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

# Log the start
echo "Starting script..." >> /tmp/my_script.log

# Update PATH for Homebrew on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Docker CLI not found! Installing..."

    case "$OSTYPE" in
        "darwin"*)
            brew install docker
            echo "Note: Only Docker CLI is installed. You will need Docker Desktop or a VM for the daemon."
            # Check if Docker Desktop is installed
            if [[ -e /Applications/Docker.app ]]; then
                open /Applications/Docker.app
            else
                echo "Docker Desktop not found. Consider installing it for the Docker daemon."
            fi
            ;;
        "linux-gnu"*)
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
        *)
            echo "Unsupported OS!"
            exit 1
            ;;
    esac
else
    echo "Docker CLI is already installed!"
fi

# Check for Python3
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found! Installing..."

    case "$OSTYPE" in
        "darwin"*)
            brew install python3
            ;;
        "linux-gnu"*)
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip
            ;;
        *)
            echo "Unsupported OS!"
            exit 1
            ;;
    esac
else
    echo "Python3 is already installed!"
fi

# Install Flask
/usr/local/bin/pip3 install Flask

# Kill process running on port 7654
/usr/sbin/lsof -t -i:7654 | xargs kill -9 2>/dev/null || true

# Run Python script
python3 app.py

# Log the end
echo "Finished script!" >> /tmp/my_script.log
