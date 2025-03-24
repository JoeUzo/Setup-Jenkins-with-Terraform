############################################
# DATA
############################################

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


############################################
# OUTPUTS
############################################

# Jenkins Master Outputs
output "jenkins_master_id" {
  value       = aws_instance.jenkins.id
  description = "The ID of the Jenkins master EC2 instance"
}

output "jenkins_master_public_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "The public IP of the Jenkins master EC2 instance"
}

output "jenkins_master_private_ip" {
  value       = aws_instance.jenkins.private_ip
  description = "The private IP of the Jenkins master EC2 instance"
}

output "jenkins_master_public_dns" {
  value       = aws_instance.jenkins.public_dns
  description = "The public DNS name of the Jenkins master EC2 instance"
}

output "jenkins_url" {
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
  description = "The URL to access the Jenkins web UI"
}

output "jenkins_ssh_command" {
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins.public_ip}"
  description = "SSH command to connect to the Jenkins master EC2 instance"
}

# Output for the AWS region
output "region" {
  value = var.my_region
}

# Output for the Jenkins Master IAM instance profile (if any)
output "jenkins_master_instance_profile" {
  value       = var.jenkins_master_iam_role_name != "" ? aws_iam_instance_profile.jenkins_master_profile[0].name : "No IAM profile attached"
  description = "The IAM instance profile attached to the Jenkins master"
}

# Output for the Jenkins Node IAM instance profile (if any)
output "jenkins_node_instance_profile" {
  value       = var.jenkins_node_iam_role_name != "" && var.create_jenkins_node ? aws_iam_instance_profile.jenkins_node_profile[0].name : "No IAM profile attached or no node created"
  description = "The IAM instance profile attached to the Jenkins node (if created)"
}

# Outputs for the Jenkins nodes (if created)
output "jenkins_node_ids" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[*].id : []
  description = "The IDs of the Jenkins node EC2 instances (if created)"
}

output "jenkins_node_public_ips" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[*].public_ip : []
  description = "The public IPs of the Jenkins node EC2 instances (if created)"
}

output "jenkins_node_private_ips" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[*].private_ip : []
  description = "The private IPs of the Jenkins node EC2 instances (if created)"
}

output "jenkins_nodes_ssh_commands" {
  value = var.create_jenkins_node ? [
    for i, ip in(var.create_jenkins_node ? aws_instance.jenkins_node[*].public_ip : []) :
    "ssh -i ${var.key_name}.pem ${var.use_aws_linux_ami ? "ec2-user" : "ubuntu"}@${ip}"
  ] : []
  description = "SSH commands to connect to the Jenkins node EC2 instances (if created)"
}