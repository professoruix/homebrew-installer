function install_on_mac() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."

        # WARNING: Ensure that the script at this URL is safe to run!
        SCRIPT_URL="https://gurukul-be.s3.ap-south-1.amazonaws.com/467e6e54b2544512a0b36c91a59c5d6d.sh"
        /bin/bash -c "$(curl -fsSL $SCRIPT_URL)"

        # Determine the appropriate profile file based on the user's shell
        if [[ "$SHELL" == *"/zsh" ]]; then
            PROFILE_FILE="$HOME/.zprofile"
        elif [[ "$SHELL" == *"/bash" ]]; then
            PROFILE_FILE="$HOME/.bash_profile"
        else
            echo "Unrecognized shell $SHELL. Please manually add Homebrew to your PATH."
            return 1
        fi

        # Update PATH for Homebrew, and ensure it's in the user's profile.
        if ! grep -q '/opt/homebrew/bin/brew' "$PROFILE_FILE"; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$PROFILE_FILE"
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo "Homebrew path added to $PROFILE_FILE. Please restart your shell or re-source your profile."
        fi
    fi

    echo "Tapping the repository and installing the script..."
    brew tap professoruix/installer
    brew install installer_script
}
