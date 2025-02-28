#!/bin/bash
terraform init \
  -backend-config="bucket=$TF_VAR_s3_bucket" \
  -backend-config="key=$TF_VAR_tfstate_key" \
  -backend-config="dynamodb_table=$TF_VAR_dynamodb_table" \
  -backend-config="region=us-east-2"
