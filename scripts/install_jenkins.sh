#!/bin/bash
# -----------------------------------------------------------------------------
# Jenkins Installation Script for Production Environment
#
# This script installs Jenkins on a Debian/Ubuntu-based system.
#
# Steps performed:
#   1. Update and upgrade system packages.
#   2. Download and store the Jenkins repository key.
#   3. Add the Jenkins repository to the system's sources list.
#   4. Refresh package lists to include the Jenkins repository.
#   5. Install required packages: fontconfig, OpenJDK 21 Runtime, and Jenkins.
#   6. Enable and start the Jenkins service.
#
# IMPORTANT:
#   - Run this script as root or using sudo.
#   - Ensure your system has recent backups and maintenance windows.
#   - This script assumes a production environment where stability
#     and proper security practices are enforced.
#
# Usage:
#   chmod +x install_jenkins.sh
#   sudo ./install_jenkins.sh
# -----------------------------------------------------------------------------

# 1. Update package lists and upgrade installed packages.
apt-get update
apt-get upgrade -y

# 2. Download the Jenkins repository key.
#    This key is used to verify the integrity of the packages downloaded.
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key

# 3. Add the Jenkins repository to the system's sources list.
#    The repository is signed with the key downloaded above to ensure authenticity.
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Update package lists again to include packages from the new Jenkins repository.
apt-get update

# 5. Install required packages:
#    a) fontconfig: A dependency required by Jenkins.
apt-get install fontconfig -y

#    b) OpenJDK 21 JRE: Jenkins requires Java to run.
#       Using the latest LTS version for better performance and security.
apt-get install -y software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update
apt-get install -y openjdk-21-jre

#    c) Jenkins: The Continuous Integration server.
apt-get install jenkins -y

# 6. Enable and start the Jenkins service.
#    Enabling ensures Jenkins starts on system boot.
systemctl enable jenkins
systemctl start jenkins

echo "Jenkins installation completed with Java 21"
# End of Script
# Jenkins is now installed and the service is running.
