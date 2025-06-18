#!/bin/bash

set -e  # Stop on errors

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install basic build tools
echo "Installing build-essential, curl, and git..."
sudo apt install -y build-essential curl git software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install VSCode
echo "Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# Install Node.js (LTS) and npm
echo "Installing Node.js (LTS) and npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python 3 and pip
echo "Installing Python 3 and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Install R and R base packages
echo "Installing R..."
sudo apt install -y r-base

# Install RStudio
echo "Installing RStudio..."
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.04.1-748-amd64.deb -O rstudio.deb
sudo apt install -y ./rstudio.deb
rm rstudio.deb

# Install Rtools — NOT required on Linux. (Rtools is Windows-specific)
echo "Skipping Rtools — not needed on Linux/Ubuntu."

echo "Done! You now have VSCode, Node.js, npm, Python 3, R, and RStudio installed."

# Final check versions
echo "== Installed Versions =="
code --version | head -n 1
node -v
npm -v
python3 --version
pip3 --version
R --version | head -n 1
rstudio --version

echo "== All installations complete =="
