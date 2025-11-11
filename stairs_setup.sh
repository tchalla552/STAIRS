#!/bin/bash

# Run this script on a fresh Ubuntu 22.04 Desktop VM with GUI
# It will install ROS 2 Humble Desktop and core Python packages used in STAIRS

# --- PREP ---
echo "[INFO] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[INFO] Installing essential utilities..."
sudo apt install -y \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    python3-pip \
    python3-venv \
    build-essential \
    nano

# --- ROS 2 REPO ---
echo "[INFO] Adding ROS 2 GPG key and apt repo..."
sudo mkdir -p /etc/apt/keyrings
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  | gpg --dearmor | sudo tee /etc/apt/keyrings/ros-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "[INFO] Updating package index again..."
sudo apt update

# --- INSTALL ROS 2 ---
echo "[INFO] Installing ROS 2 Humble Desktop..."
sudo apt install -y ros-humble-desktop

# --- ROS ENV SETUP ---
echo "[INFO] Adding ROS setup to bashrc..."
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# --- PYTHON ENV ---
echo "[INFO] Installing Python packages for Jupyter and ML..."
pip3 install --upgrade pip

pip3 install \
    jupyterlab \
    numpy \
    pandas \
    matplotlib \
    scikit-learn

# Set Ubuntu to boot into GUI mode
sudo systemctl set-default graphical.target

# --- DONE ---
echo "[SUCCESS] STAIRS environment is ready."
echo "You can now run: jupyter lab"