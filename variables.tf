variable "my_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.large"
}

variable "key_name" {
  type    = string
  default = "my-key"
}

variable "my_ec2_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "Jenkins"
}

variable "associate_pub_ip_address" {
  description = "Associate a public IP address with the EC2 instance"
  type        = bool
  default     = true
}



#########################################
#VPC MODULE
#########################################

variable "vpc_owner" {
  description = "The owner of the VPC"
  type        = string
}

variable "vpc_use" {
  description = "The purpose of the VPC"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_availability_zones" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
}