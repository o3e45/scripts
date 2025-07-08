#!/bin/bash

set -e

# === CONFIGURATION ===
WAZUH_MANAGER="10.42.31.201"
AGENT_NAME="$(hostname)"
AGENT_GROUP="odh-core"
PACKAGE_URL="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb"
PACKAGE_FILE="wazuh-agent_4.12.0-1_amd64.deb"
LOG_FILE="/var/log/wazuh-agent-install.log"

echo "[*] Installing Wazuh agent on $AGENT_NAME..." | tee -a "$LOG_FILE"

# === CHECK IF ALREADY INSTALLED ===
if dpkg -l | grep -q wazuh-agent; then
  echo "[!] Wazuh agent is already installed. Skipping installation." | tee -a "$LOG_FILE"
  exit 0
fi

# === DEPENDENCIES ===
echo "[*] Installing dependencies..." | tee -a "$LOG_FILE"
sudo apt-get update
sudo apt-get install -y lsb-release curl gnupg

# === DOWNLOAD PACKAGE ===
echo "[*] Downloading Wazuh agent package..." | tee -a "$LOG_FILE"
curl -s -O "$PACKAGE_URL"

# === INSTALL PACKAGE ===
echo "[*] Installing package..." | tee -a "$LOG_FILE"
sudo dpkg -i "./$PACKAGE_FILE" || true  # dpkg might fail on first run due to missing deps
sudo apt-get install -f -y              # fix dependencies

# === CLEANUP ===
rm -f "./$PACKAGE_FILE"

# === PATCH CONFIGURATION ===
CONFIG_FILE="/var/ossec/etc/ossec.conf"

if grep -q "<address>MANAGER_IP</address>" "$CONFIG_FILE"; then
  echo "[*] Patching manager IP in ossec.conf..." | tee -a "$LOG_FILE"
  sudo sed -i "s|<address>MANAGER_IP</address>|<address>$WAZUH_MANAGER</address>|" "$CONFIG_FILE"
fi

if grep -q "<agent_name>.*</agent_name>" "$CONFIG_FILE"; then
  echo "[*] Patching agent name..." | tee -a "$LOG_FILE"
  sudo sed -i "s|<agent_name>.*</agent_name>|<agent_name>$AGENT_NAME</agent_name>|" "$CONFIG_FILE"
fi

if ! grep -q "<group>$AGENT_GROUP</group>" "$CONFIG_FILE"; then
  echo "[*] Setting group to '$AGENT_GROUP'..." | tee -a "$LOG_FILE"
  sudo sed -i "s|</client>|  <group>$AGENT_GROUP</group>\n  </client>|" "$CONFIG_FILE"
fi

# === START AGENT ===
echo "[*] Enabling and starting wazuh-agent..." | tee -a "$LOG_FILE"
sudo systemctl daemon-reexec
sudo systemctl enable wazuh-agent --now

echo "[✓] Wazuh agent installed and running as '$AGENT_NAME' in group '$AGENT_GROUP'" | tee -a "$LOG_FILE"
