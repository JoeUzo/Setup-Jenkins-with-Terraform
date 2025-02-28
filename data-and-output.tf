############################################
# DATA
############################################

data "aws_ami" "ubuntu" {
    most_recent = true
    
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-24.04-amd64-server-*"]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
      name = "architecture"
      values = ["x86_64"]
    }   
}


############################################
# OUTPUTS
############################################

output "instance_ids" {
  value = [for instance in aws_instance.my-ec2 : instance.id]
}

# Output for the AWS region
output "region" {
  value = var.my_region
}