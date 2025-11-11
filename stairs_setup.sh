#!/bin/bash

# STAIRS Ubuntu setup script
# Prepares a clean Ubuntu environment for GUI-based ROS 2 and JupyterLab work

set -e

echo "Starting STAIRS setup..."

# Set noninteractive mode for APT
export DEBIAN_FRONTEND=noninteractive

# Ensure base tools are installed first
sudo apt update && sudo apt install -y \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git

# Temporarily prevent key services from restarting during install
sudo systemctl mask gdm3 || true
sudo systemctl mask dbus || true

# Add ROS 2 GPG key and source list
sudo mkdir -p /etc/apt/keyrings
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo tee /etc/apt/keyrings/ros-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list

# Update sources and install ROS 2 Desktop (with GUI tools)
sudo apt update
sudo apt install -y ros-humble-desktop

# Install full Ubuntu Desktop (GUI environment)
sudo apt install -y ubuntu-desktop

# Install Python tools for JupyterLab and ML libraries
sudo apt install -y python3-pip python3-venv
pip3 install --upgrade pip
pip3 install jupyterlab numpy pandas matplotlib scikit-learn

# Enable ROS environment setup on login
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Re-enable masked services
sudo systemctl unmask gdm3 || true
sudo systemctl unmask dbus || true

# Set GUI to start by default and start GDM
sudo systemctl set-default graphical.target
sudo systemctl enable gdm3
sudo systemctl restart gdm3

echo "✅ STAIRS setup complete. Reboot the VM to begin using the desktop environment."
