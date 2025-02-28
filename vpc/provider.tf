terraform {
  required_version = "~> 1.9"
  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89"
      }
  } 

# pass this during terraform init
#   backend "s3" {
#     bucket = "TF_VAR_s3_bucket"
#     key    = "TF_VAR_tfstate_key"
#     dynamodb_table = "TF_VAR_dynamodb_table
#     region = "us-east-2"
#   }
}


provider "aws" {
  region = var.my_region
}
