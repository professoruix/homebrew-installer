# Environment Setup Script

This script automates the environment setup for Docker, Python3, and Flask. It supports macOS, Linux, and Windows Subsystem for Linux (WSL).

## Prerequisites

- Git installed on your machine. If not, download and install from [here](https://git-scm.com/downloads).
- For Windows users, make sure you're using WSL. Instructions for installation can be found [here](https://docs.microsoft.com/windows/wsl/install).

## Getting Started

Follow these steps to run the environment setup script:

### 1. Clone the Repository

First, clone the repository to your local machine. Open your terminal and run:

```bash
git clone https://github.com/professoruix/homebrew-installer
```

### 2. Navigate to the Script's Directory

Change to the directory containing the script:

```bash
cd homebrew-installer
```

### 3. Set Script Permissions

Before running the script, you need to ensure it's executable. You can do this with the following command:

```bash
chmod +x installer.sh
```

### 4. Run the Script

Now, you can run the script:

```bash
./installer.sh
```

The script will handle the environment setup from here, following the procedures defined within it.

### Optional Parameters

The script includes optional parameters for specific functionalities:

--help: Display a help message and exit.
--version: Output the version of the script and exit.
For example, you can check the version of the script by running:

```bash
./installer.sh --version
```

### Troubleshooting

If you encounter issues:

- Ensure your command line tools and Git are up to date.
- Verify your user has permission to execute the script.
- Check the script output for any error messages and consult the Troubleshooting section of this README.
- Ensure Docker Desktop is running if you're using Docker (applicable for Docker users).

### Support

For further assistance or any questions, please open an issue in this repository.

