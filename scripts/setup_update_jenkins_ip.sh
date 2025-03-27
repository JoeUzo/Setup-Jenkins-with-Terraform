#!/bin/bash
set -e

# Define destination for the update script
DEST_SCRIPT="/usr/local/bin/update_jenkins_ip.sh"

# Write the update script to the destination
cat <<'EOF' > "$DEST_SCRIPT"
#!/bin/bash
# Path to the Jenkins configuration file
CONFIG_FILE="/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"

# New IP address
NEW_IP=$(curl -s icanhazip.com)

# Replace the IP address in the configuration file
sudo sed -i.bak "s|http://[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:8080/|http://$NEW_IP:8080/|g" "$CONFIG_FILE"

echo "IP address $NEW_IP updated successfully in $CONFIG_FILE"

# Restart Jenkins to apply the change
sudo systemctl restart jenkins

echo "Jenkins has been restarted"
EOF

# Make the update script executable
chmod +x "$DEST_SCRIPT"
echo "Copied update script to $DEST_SCRIPT and set executable permissions."

# Create the systemd service file
SERVICE_FILE="/etc/systemd/system/update-jenkins-ip.service"
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Update Jenkins IP at startup
After=network.target

[Service]
Type=oneshot
ExecStart=$DEST_SCRIPT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "Created systemd service file at $SERVICE_FILE."

# Reload systemd to recognize the new service, then enable and start it
sudo systemctl daemon-reload
sudo systemctl enable update-jenkins-ip.service
sudo systemctl start update-jenkins-ip.service

echo "Systemd service 'update-jenkins-ip.service' enabled and started."
