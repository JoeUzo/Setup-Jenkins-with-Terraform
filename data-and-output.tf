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