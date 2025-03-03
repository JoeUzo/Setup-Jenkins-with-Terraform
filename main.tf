module "vpc_module" {
  source                 = "./vpc"
  my_region              = var.my_region
  vpc_owner              = var.vpc_owner
  vpc_use                = var.vpc_use
  vpc_availability_zones = var.vpc_availability_zones
  vpc_cidr               = var.vpc_cidr
  vpc_public_subnets     = var.vpc_public_subnets
  vpc_private_subnets    = var.vpc_private_subnets
  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu_ami.id
  associate_public_ip_address = var.associate_pub_ip_address
  subnet_id                   = module.vpc_module.public_subnets[0]
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.jenkins-sg.id]

  user_data = file("scripts/install_jenkins.sh")

  tags = {
    Name = var.my_ec2_name
  }

  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
      security_groups
    ]
  }
}