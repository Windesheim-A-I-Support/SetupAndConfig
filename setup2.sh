#!/bin/bash

set -e

# === Ask user for GitHub email ===
echo "Enter your GitHub email for SSH key setup:"
read -r GITHUB_EMAIL

# === Ask user for project folder path ===
echo "Enter the full path to your project workspace (example: /home/yourname/projects):"
read -r PROJECT_PATH
mkdir -p "$PROJECT_PATH"

# === Ask if user wants to install VSCode extensions ===
echo "Do you want to install recommended VSCode extensions? (y/n)"
read -r INSTALL_EXTENSIONS

# === 1. Update system ===
echo "=== 1. Updating system ==="
sudo apt update && sudo apt upgrade -y

# === 2. Install core tools ===
echo "=== 2. Installing core tools ==="
sudo apt install -y build-essential curl git software-properties-common apt-transport-https ca-certificates gnupg lsb-release wget

# === 3. Install VSCode ===
echo "=== 3. Installing Visual Studio Code ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# === 4. Install Node.js LTS and npm ===
echo "=== 4. Installing Node.js LTS and npm ==="
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# === 5. Install Python 3 and pip ===
echo "=== 5. Installing Python 3 and pip ==="
sudo apt install -y python3 python3-pip python3-venv

# === 6. Install R and RStudio ===
echo "=== 6. Installing R and RStudio ==="
sudo apt install -y r-base
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.04.1-748-amd64.deb -O rstudio.deb
sudo apt install -y ./rstudio.deb
rm rstudio.deb

# === 7. Setup Git + SSH ===
echo "=== 7. Setting up Git + SSH ==="
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    echo "== Copy this key and add to GitHub: =="
    cat ~/.ssh/id_ed25519.pub
    echo "== Go to GitHub → Settings → SSH keys → New SSH Key"
    read -p "Press Enter after adding SSH key to GitHub..."
fi

# Test connection
ssh -T git@github.com || echo "⚠️ SSH connection to GitHub failed (probably you need to authorize key first)"

# === 8. Install NVM (Node Version Manager) ===
echo "=== 8. Installing NVM (Node Version Manager) ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM for the current session
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

# === 9. Install latest Node.js via NVM ===
echo "=== 9. Installing latest Node.js via NVM ==="
nvm install --lts
nvm use --lts
npm install -g yarn pnpm typescript eslint prettier

# === 10. Install Python virtualenv ===
echo "=== 10. Installing Python virtualenv ==="
pip3 install -U virtualenv

# === 11. Set workspace permissions ===
echo "=== 11. Setting workspace permissions ==="
sudo chown -R $USER:$USER "$PROJECT_PATH"

# === 12. Optionally install VSCode extensions ===
if [[ "$INSTALL_EXTENSIONS" == "y" || "$INSTALL_EXTENSIONS" == "Y" ]]; then
    echo "=== Installing VSCode extensions ==="
    code --install-extension eamodio.gitlens
    code --install-extension ms-python.python
    code --install-extension ms-toolsai.jupyter
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension ms-vscode.cpptools
    code --install-extension rdebugger.r-debugger
    code --install-extension ikuyadeu.r
else
    echo "=== Skipping VSCode extensions install ==="
fi

# === 13. Final check ===
echo "=== 13. Final check of installed versions ==="
echo "VSCode version: $(code --version | head -n 1)"
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "Python version: $(python3 --version)"
echo "pip version: $(pip3 --version)"
echo "R version: $(R --version | head -n 1)"
echo "RStudio version: $(rstudio --version)"

echo "=== ✅ All tools installed and ready ==="
