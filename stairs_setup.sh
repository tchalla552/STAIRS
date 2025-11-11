#!/bin/bash

set -e

# -----------------------------
# FLAGS: --vmware or --utm
# -----------------------------
FORCE_VMWARE=false
FORCE_UTM=false

for arg in "$@"; do
    case $arg in
        --vmware)
        FORCE_VMWARE=true
        shift
        ;;
        --utm)
        FORCE_UTM=true
        shift
        ;;
    esac
done

# -----------------------------
# Detect Hypervisor (unless overridden)
# -----------------------------
detect_hypervisor() {
    if [ "$FORCE_VMWARE" = true ]; then
        echo "Hypervisor manually set to VMware."
        echo "vmware"
    elif [ "$FORCE_UTM" = true ]; then
        echo "Hypervisor manually set to UTM (QEMU)."
        echo "utm"
    else
        PRODUCT_NAME=$(dmidecode -s system-product-name 2>/dev/null || echo "")
        if echo "$PRODUCT_NAME" | grep -qi "vmware"; then
            echo "Detected VMware environment."
            echo "vmware"
        elif systemd-detect-virt | grep -qi "qemu"; then
            echo "Detected UTM/QEMU environment."
            echo "utm"
        else
            echo "Unknown environment. Defaulting to UTM config."
            echo "utm"
        fi
    fi
}

HYPERVISOR=$(detect_hypervisor)

# -----------------------------
# Update + Base packages
# -----------------------------
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing core packages..."
sudo apt install -y curl gnupg lsb-release wget git nano gnome-terminal

# -----------------------------
# Prevent Ubuntu Pro prompts and version upgrade nags
# -----------------------------
echo "Disabling release upgrade prompts..."
sudo sed -i 's/^Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades

echo "Disabling Ubuntu Pro auto-suggestions..."
sudo touch /etc/cloud/cloud-init.disabled

# -----------------------------
# Install Ubuntu Desktop
# -----------------------------
echo "Installing Ubuntu Desktop..."
sudo apt install -y ubuntu-desktop gdm3

echo "Enabling GDM3 to start on boot..."
sudo systemctl enable gdm3

# -----------------------------
# Install VMware Tools or QEMU Guest Agent
# -----------------------------
if [ "$HYPERVISOR" = "vmware" ]; then
    echo "Installing VMware Tools..."
    sudo apt install -y open-vm-tools open-vm-tools-desktop
elif [ "$HYPERVISOR" = "utm" ]; then
    echo "Installing QEMU Guest Agent..."
    sudo apt install -y qemu-guest-agent spice-vdagent
fi

# -----------------------------
# Add ROS 2 Humble Repository
# -----------------------------
echo "Setting up ROS 2 Humble sources..."
sudo mkdir -p /etc/apt/keyrings
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | \
    sudo tee /etc/apt/keyrings/ros-archive-keyring.gpg >/dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/ros2.list

sudo apt update
sudo apt install -y ros-humble-desktop

# -----------------------------
# Add ROS to bash session
# -----------------------------
echo "Adding ROS environment to bashrc..."
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# -----------------------------
# Install Python tools
# -----------------------------
echo "Installing Python packages..."
sudo apt install -y python3-pip python3-venv
pip3 install --upgrade pip
pip3 install jupyterlab numpy pandas matplotlib scikit-learn

echo "STAIRS environment setup complete. Reboot your VM to start the desktop environment."
