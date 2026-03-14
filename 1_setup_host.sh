#!/usr/bin/env bash
#
sudo apt update
sudo apt install -y frr ethtool tcpdump tmux vim git iputils-ping build-essential

# 2. Enable IP Forwarding (Critical for a router lab)
sudo sysctl -w net.ipv4.ip_forward=1

# 3. Disable FRR on the host
sudo systemctl stop frr
sudo systemctl disable frr

sudo ufw disable
sudo nft list ruleset
sudo nft flush ruleset
