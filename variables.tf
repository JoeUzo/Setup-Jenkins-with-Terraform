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
# JENKINS NODE/SLAVE
#########################################

variable "create_jenkins_node" {
  description = "Whether to create a Jenkins node/slave EC2 instance"
  type        = bool
  default     = false
}

variable "jenkins_node_instance_type" {
  description = "The instance type for the Jenkins node/slave"
  type        = string
  default     = "t3.large"  # Suitable for running Terraform and AWS CLI
}

variable "jenkins_node_name" {
  description = "The name of the Jenkins node/slave EC2 instance"
  type        = string
  default     = "Jenkins-Node"
}

variable "jenkins_node_ami" {
  description = "The AMI ID for the Jenkins node/slave (if not specified, will use the same as the master)"
  type        = string
  default     = ""  # Empty means use the same AMI as the Jenkins master
}

variable "use_aws_linux_ami" {
  description = "Whether to use Amazon Linux 2 AMI instead of Ubuntu for the Jenkins node"
  type        = bool
  default     = false
}

variable "install_terraform_aws" {
  description = "Whether to install Terraform and AWS CLI on the Jenkins node"
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

#########################################
# IAM MODULE
#########################################

# Note: The following variable is defined in iam.tf:
# - existing_iam_policy_arns: List of existing IAM policy ARNs to attach to the Jenkins instance role