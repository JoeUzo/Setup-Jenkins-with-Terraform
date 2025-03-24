############################################
# IAM Resources for Jenkins EC2 Instances
############################################

# Variables for existing IAM roles
variable "jenkins_master_iam_role_name" {
  description = "Name of an existing IAM role to attach to the Jenkins master instance"
  type        = string
  default     = ""
}

variable "jenkins_node_iam_role_name" {
  description = "Name of an existing IAM role to attach to the Jenkins node instance"
  type        = string
  default     = ""
}

# Create instance profile for Jenkins master using the existing role
resource "aws_iam_instance_profile" "jenkins_master_profile" {
  count = var.jenkins_master_iam_role_name != "" ? 1 : 0
  name  = "jenkins-master-profile"
  role  = var.jenkins_master_iam_role_name
}

# Create instance profile for Jenkins node using the existing role
resource "aws_iam_instance_profile" "jenkins_node_profile" {
  count = var.jenkins_node_iam_role_name != "" && var.create_jenkins_node ? 1 : 0
  name  = "jenkins-node-profile"
  role  = var.jenkins_node_iam_role_name
} 