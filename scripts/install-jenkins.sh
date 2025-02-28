#!/bin/bash

# Update package list
sudo apt-get -y update

# Add Jenkins repository and install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    
# Install Java and Jenkins
sudo apt-get -y install fontconfig openjdk-17-jre
sudo apt-get -y install jenkins

# Start and enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins