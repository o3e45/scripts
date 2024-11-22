#!/bin/bash

# Update and install required packages
apt-get update && apt-get upgrade -y
apt-get install -y tmux zsh unzip zip git python3 python3-pip

# Change the default shell for the root user to zsh
chsh -s /usr/bin/zsh root

# Install Oh My Zsh
cd /root
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install.sh
/usr/bin/zsh -c "/root/install.sh --unattended"

# Download and unzip ZenithProxy
cd /root
mkdir ZenithProxy
cd ZenithProxy
wget https://github.com/rfresh2/ZenithProxy/releases/download/launcher-v3/ZenithProxy-launcher-linux-amd64.zip
unzip ZenithProxy-launcher-linux-amd64.zip

# Clean up the install script
rm -f /root/install.sh

# Reboot the system
reboot
