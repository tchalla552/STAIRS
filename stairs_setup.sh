#!/bin/bash

# STAIRS Ubuntu setup script
# Prepares a clean Ubuntu environment for GUI-based ROS 2 and JupyterLab work

set -e

echo "Starting STAIRS setup..."

# Set noninteractive mode for APT
export DEBIAN_FRONTEND=noninteractive

# Auto-restart daemons during apt upgrades without user prompt
sudo sed -i 's/#\$nrconf{restart} =.*/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf

# Prevent release upgrade to Ubuntu 24.04
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

# Suppress Ubuntu Pro and related upgrade prompts
sudo pro config set apt_news=false || true
sudo chmod -x /etc/update-motd.d/50-motd-news || true

# Ensure fully non-interactive apt behavior
export DEBIAN_FRONTEND=noninteractive
sudo sed -i 's/#\$nrconf{restart} =.*/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf

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

# === Create Desktop Shortcuts ===
DESKTOP_DIR="/home/$USER/Desktop"
mkdir -p $DESKTOP_DIR

# JupyterLab Launcher
cat <<EOF > $DESKTOP_DIR/JupyterLab.desktop
[Desktop Entry]
Name=JupyterLab
Comment=Launch JupyterLab
Exec=sh -c "jupyter-lab"
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;
EOF

# RViz Launcher
cat <<EOF > $DESKTOP_DIR/RViz.desktop
[Desktop Entry]
Name=RViz
Comment=Launch ROS 2 Visualization Tool
Exec=sh -c "source /opt/ros/humble/setup.bash && rviz2"
Icon=applications-graphics
Terminal=true
Type=Application
Categories=Development;
EOF

chmod +x $DESKTOP_DIR/*.desktop
chown $USER:$USER $DESKTOP_DIR/*.desktop

echo "✅ STAIRS setup complete. Reboot the VM to begin using the desktop environment."
