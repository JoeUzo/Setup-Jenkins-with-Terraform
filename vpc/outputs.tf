output "vpc_id" {
  description = "value of the VPC ID"
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "value of vpc cidr block"
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}