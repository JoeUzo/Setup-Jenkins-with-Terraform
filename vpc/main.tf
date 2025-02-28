module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.19.0"

    name = local.name_
    cidr = var.vpc_cidr

    azs = var.vpc_azs
    public_subnets  = var.vpc_public_subnets
    private_subnets = var.vpc_private_subnets

    enable_nat_gateway = var.vpc_enable_nat_gateway
    single_nat_gateway = var.vpc_single_nat_gateway

    tags = local.common_tags

    public_subnet_tags = {
      Type = "Public Subnets"
    }
    private_subnet_tags = {
      Type = "Private Subnets"
    }

    
}