#!/bin/bash

set -e

echo "[STAIRS Setup] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[STAIRS Setup] Installing essentials..."
sudo apt install -y \
    curl \
    gnupg \
    lsb-release \
    build-essential \
    software-properties-common

echo "[STAIRS Setup] Adding ROS 2 Humble repository..."
sudo mkdir -p /etc/apt/keyrings
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo tee /etc/apt/keyrings/ros-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "[STAIRS Setup] Updating package list after adding ROS 2 repo..."
sudo apt update

echo "[STAIRS Setup] Installing ROS 2 Humble Desktop (GUI tools)..."
sudo apt install -y ros-humble-desktop

echo "[STAIRS Setup] Sourcing ROS environment..."
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

echo "[STAIRS Setup] Installing Ubuntu Desktop and GDM..."
sudo apt install -y ubuntu-desktop gdm3

echo "[STAIRS Setup] Enabling GUI to start at boot..."
sudo systemctl set-default graphical.target
sudo systemctl enable gdm3

echo "[STAIRS Setup] Installing Python packages and JupyterLab..."
sudo apt install -y python3-pip python3-venv
pip3 install --upgrade pip
pip3 install jupyterlab numpy pandas matplotlib scikit-learn

echo "[STAIRS Setup] All steps complete."
echo "You may want to reboot to start Ubuntu Desktop: sudo reboot"
