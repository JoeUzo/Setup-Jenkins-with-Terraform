############################################
# EKS IAM Role Configuration
############################################

# Variables for EKS IAM role
variable "create_eks_iam_role" {
  description = "Whether to create a new IAM role for EKS management (set to false to use existing roles)"
  type        = bool
  default     = true
}

variable "existing_eks_iam_role_name" {
  description = "Name of an existing IAM role for EKS management (if not creating a new one)"
  type        = string
  default     = ""
}

variable "personal_aws_account_id" {
  description = "Your personal AWS account ID to add to the trust policy"
  type        = string
  default     = ""
}

variable "personal_user_name" {
  description = "Your personal IAM user name to add to the trust policy"
  type        = string
  default     = ""
}

variable "enable_full_s3_access" {
  description = "Whether to enable full S3 access (not just Terraform state buckets)"
  type        = bool
  default     = false
}

# Create an IAM role for EKS management
resource "aws_iam_role" "eks_management_role" {
  count = var.create_eks_iam_role ? 1 : 0
  
  name = "eks-management-role"
  
  # Trust policy allows both EC2 (for Jenkins nodes) and the specified personal user to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ], 
    var.personal_aws_account_id != "" && var.personal_user_name != "" ? [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.personal_aws_account_id}:user/${var.personal_user_name}"
        }
        Action = "sts:AssumeRole"
      }
    ] : [])
  })

  tags = {
    Name = "EKS-Management-Role"
    Purpose = "Allow Jenkins nodes and personal users to manage EKS clusters"
  }
}

# Attach the AmazonEKSClusterPolicy for basic EKS management
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.create_eks_iam_role ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach the AmazonEKSServicePolicy for EKS service management
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  count      = var.create_eks_iam_role ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Attach the AmazonEKSWorkerNodePolicy for managing worker nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count      = var.create_eks_iam_role ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach the AmazonEC2ContainerRegistryReadOnly for pulling container images
resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
  count      = var.create_eks_iam_role ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optionally attach the AmazonS3FullAccess policy for broader S3 management
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  count      = var.create_eks_iam_role && var.enable_full_s3_access ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create a custom policy for Terraform S3 backend and DynamoDB state locking
resource "aws_iam_policy" "terraform_backend_policy" {
  count       = var.create_eks_iam_role && !var.enable_full_s3_access ? 1 : 0
  name        = "TerraformBackendAccess"
  description = "Allows access to S3 and DynamoDB for Terraform remote state management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:HeadBucket"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/*"
      }
    ]
  })
}

# Attach the Terraform backend policy
resource "aws_iam_role_policy_attachment" "terraform_backend_attachment" {
  count      = var.create_eks_iam_role && !var.enable_full_s3_access ? 1 : 0
  role       = aws_iam_role.eks_management_role[0].name
  policy_arn = aws_iam_policy.terraform_backend_policy[0].arn
}

# Create instance profile for the EKS management role
resource "aws_iam_instance_profile" "eks_profile" {
  count = var.create_eks_iam_role ? 1 : 0
  name  = "eks-management-profile"
  role  = aws_iam_role.eks_management_role[0].name
}

# Output the role name for reference
output "eks_management_role_name" {
  value = var.create_eks_iam_role ? aws_iam_role.eks_management_role[0].name : var.existing_eks_iam_role_name
  description = "The name of the IAM role for EKS management (either newly created or existing)"
}

output "eks_management_role_arn" {
  value = var.create_eks_iam_role ? aws_iam_role.eks_management_role[0].arn : (
    var.existing_eks_iam_role_name != "" ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.existing_eks_iam_role_name}" : null
  )
  description = "The ARN of the IAM role for EKS management (either newly created or existing)"
}

# Get the current AWS account ID for role ARN construction
data "aws_caller_identity" "current" {} 