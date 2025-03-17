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

output "instance_ids" {
  value = aws_instance.jenkins.id
}

# Output for the AWS region
output "region" {
  value = var.my_region
}

# Output for the IAM role
output "jenkins_role_name" {
  value = aws_iam_role.jenkins_role.name
}

# Output for the IAM instance profile
output "jenkins_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins_profile.name
}

# Outputs for the Jenkins node (if created)
output "jenkins_node_id" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[0].id : null
  description = "The ID of the Jenkins node EC2 instance (if created)"
}

output "jenkins_node_public_ip" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[0].public_ip : null
  description = "The public IP of the Jenkins node EC2 instance (if created)"
}

output "jenkins_node_private_ip" {
  value       = var.create_jenkins_node ? aws_instance.jenkins_node[0].private_ip : null
  description = "The private IP of the Jenkins node EC2 instance (if created)"
}