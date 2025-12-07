#!/bin/bash

echo "🧪 Verifying STAIRS VM setup..."

# OS check
echo -n "✅ Ubuntu version: "; lsb_release -d

# Internet check
ping -c 1 github.com >/dev/null 2>&1 && echo "✅ Internet connectivity: OK" || echo "❌ No internet access"

# Python check
python3 --version && echo "✅ Python 3 is installed" || echo "❌ Python 3 not found"

# Pip check
pip3 --version && echo "✅ pip is installed" || echo "❌ pip not found"

# Python packages
for pkg in numpy pandas matplotlib scikit-learn jupyterlab; do
    pip3 show $pkg >/dev/null 2>&1 && echo "✅ $pkg installed" || echo "❌ $pkg missing"
done

# JupyterLab check
jupyter lab --version && echo "✅ JupyterLab is working" || echo "❌ JupyterLab not found"

# ROS 2
source /opt/ros/humble/setup.bash
ros2 pkg list >/dev/null 2>&1 && echo "✅ ROS 2 is configured" || echo "❌ ROS 2 not working"
which rviz2 >/dev/null 2>&1 && echo "✅ RViz2 is installed" || echo "❌ RViz2 not found"

# Git
git --version && echo "✅ Git is installed" || echo "❌ Git not found"

echo "🧪 Verification complete."
