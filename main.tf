module "vpc_module" {
  source = "./vpc"
}

resource "aws_instance" "jenkins" {
  ami = data.aws_ami.ubuntu
  subnet_id = module.vpc_module.public_subnets[0]
  instance_type = var.instance_type
  key_name = var.key_name
  security_groups = [aws_security_group.jenkins-sg.id]

  user_data = file("install-jenkins.sh")
  
  tags = {
    Name = each.key
  }

  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
      security_groups
    ]
  }
}