############################################
# IAM Resources for Jenkins EC2 Instance
############################################

# Create an IAM role for the Jenkins EC2 instance
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "jenkins-role"
  }
}

# Create a variable for existing IAM policies to attach
variable "existing_iam_policy_arns" {
  description = "List of existing IAM policy ARNs to attach to the Jenkins instance role"
  type        = list(string)
  default     = []
}

# Attach existing policies if provided
resource "aws_iam_role_policy_attachment" "existing_policies" {
  count      = length(var.existing_iam_policy_arns)
  role       = aws_iam_role.jenkins_role.name
  policy_arn = var.existing_iam_policy_arns[count.index]
}

# Create an instance profile for the Jenkins EC2 instance
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
} 