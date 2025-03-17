#!/bin/bash

# Update the system
apt-get update
apt-get upgrade -y

# Install necessary packages
apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip jq

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Terraform
TF_VERSION="1.9.0"
wget "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
unzip "terraform_${TF_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
rm "terraform_${TF_VERSION}_linux_amd64.zip"

# Install kubectl (for EKS interaction)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install eksctl (for EKS management)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install Docker (useful for building container images)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
rm get-docker.sh

# Install Jenkins agent
mkdir -p /home/ubuntu/jenkins-agent
chown -R ubuntu:ubuntu /home/ubuntu/jenkins-agent

# Install Java (required for Jenkins agent)
apt-get install -y openjdk-11-jdk

# Create a directory for Terraform projects
mkdir -p /home/ubuntu/terraform-projects
chown -R ubuntu:ubuntu /home/ubuntu/terraform-projects

# Add helpful aliases
cat >> /home/ubuntu/.bashrc << 'EOF'
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfi='terraform init'
EOF

echo "Terraform, AWS CLI, and Jenkins agent setup completed!" 