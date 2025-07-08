#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# === CONFIGURATION ===
WAZUH_MANAGER="10.42.31.201"
AGENT_NAME="$(hostname)"
PACKAGE_URL="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb"
PACKAGE_FILE="wazuh-agent_4.12.0-1_amd64.deb"

# === INSTALLATION ===
echo "[*] Downloading Wazuh agent package..."
curl -s -O "$PACKAGE_URL"

echo "[*] Installing Wazuh agent with node name: $AGENT_NAME"
sudo WAZUH_MANAGER="$WAZUH_MANAGER" WAZUH_AGENT_NAME="$AGENT_NAME" dpkg -i "./$PACKAGE_FILE"

echo "[*] Cleaning up .deb package..."
rm -f "./$PACKAGE_FILE"

echo "[*] Enabling and starting Wazuh agent..."
sudo systemctl daemon-reexec
sudo systemctl enable wazuh-agent --now

echo "[✓] Wazuh agent installed and running as '$AGENT_NAME'."
