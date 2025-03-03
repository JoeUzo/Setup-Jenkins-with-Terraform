variable "my_region" {
  type = string
  default = "us-east-1"
}

variable "instance_type" {
  type = string
  default = "t2.large"
}

variable "key_name" {
  type = string
  default = "my-key"
}

variable "vpc_owner" {
  description = "The owner of the VPC"
  type        = string
}

variable "vpc_use" {
  description = "The purpose of the VPC"
  type        = string
}
