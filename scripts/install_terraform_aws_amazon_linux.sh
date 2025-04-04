#!/bin/bash

# Update the system
yum update -y

# Install necessary packages
yum install -y wget unzip jq git

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

# Install Helm (for Kubernetes package management)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install eksctl (for EKS management)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install Docker
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install the latest Java (required for Jenkins agent)
# Amazon Linux 2 doesn't have Java 21 in the standard repos, so we'll use Amazon Corretto
yum install -y java-21-amazon-corretto
# Fallback to Java 17 if 21 is not available
if [ $? -ne 0 ]; then
    echo "Java 21 not available, installing Java 17..."
    yum install -y java-17-amazon-corretto
fi

# Create Jenkins agent directory
mkdir -p /home/ec2-user/jenkins-agent
chown -R ec2-user:ec2-user /home/ec2-user/jenkins-agent

# Create a directory for Terraform projects
mkdir -p /home/ec2-user/terraform-projects
chown -R ec2-user:ec2-user /home/ec2-user/terraform-projects

# Add helpful aliases
cat >> /home/ec2-user/.bashrc << 'EOF'
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfi='terraform init'
EOF

# Display Java version
java_version=$(java -version 2>&1 | head -1)
echo "Terraform, AWS CLI, Helm, and Jenkins agent setup completed with $java_version!" 