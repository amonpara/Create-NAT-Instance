#!/bin/bash

# ======================================================
# AWS NAT Instance Setup Script by Abhishek Monpara
# ======================================================
# Description:
# This script configures an EC2 instance as a NAT Instance
# for private subnet internet access.
#
# Tested On:
# - Amazon Linux 2
# - Amazon Linux 2023
#
# Usage:
# 1. Launch EC2 in PUBLIC subnet
# 2. Attach Public IP / Elastic IP
# 3. Disable Source/Destination Check manually in AWS Console
# 4. SSH into instance
# 5. Run:
#    chmod +x nat-setup.sh
#    sudo ./nat-setup.sh
# ======================================================

set -e

echo "========================================"
echo "AWS NAT Instance Setup Script by Abhishek Monpara"
echo "========================================"

# Detect default network interface
INTERFACE=$(ip route | grep default | awk '{print $5}')

if [ -z "$INTERFACE" ]; then
  echo "ERROR: Could not detect network interface"
  exit 1
fi

echo "Detected network interface: $INTERFACE"

# Enable IP Forwarding

echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

# Persist after reboot
if ! grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
fi

# Install iptables services

echo "Installing iptables-services..."

if command -v yum &> /dev/null; then
  sudo yum install -y iptables-services
elif command -v dnf &> /dev/null; then
  sudo dnf install -y iptables-services
else
  echo "ERROR: Neither yum nor dnf found"
  exit 1
fi

# Flush existing NAT rules

echo "Flushing existing NAT rules..."
sudo iptables -t nat -F

# Configure MASQUERADE rule

echo "Configuring NAT masquerading on interface: $INTERFACE"
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE

# Allow forwarding traffic
sudo iptables -A FORWARD -i $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -o $INTERFACE -j ACCEPT

# Save iptables rules

echo "Saving iptables rules..."
sudo service iptables save

# Enable iptables on boot

echo "Enabling iptables service..."
sudo systemctl enable iptables
sudo systemctl restart iptables

# Display status

echo "========================================"
echo "NAT Configuration Completed Successfully"
echo "========================================"

echo "\nIP Forwarding Status:"
cat /proc/sys/net/ipv4/ip_forward

echo "\nCurrent NAT Rules:"
sudo iptables -t nat -L -n -v

echo "\nIMPORTANT NEXT STEPS:"
echo "1. Disable Source/Destination Check in AWS Console"
echo "2. Update private subnet route table:"
echo "   0.0.0.0/0 -> NAT Instance ENI or Instance ID"
echo "3. Ensure NAT Instance is in PUBLIC subnet"
echo "4. Ensure public subnet has route to Internet Gateway"
echo "5. Ensure NAT instance has Public IP or Elastic IP"

echo "\nTest from private EC2:"
echo "curl google.com"

echo "========================================"
echo "Setup Finished"
echo "========================================"
