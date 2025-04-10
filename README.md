# Jenkins on AWS with Terraform

This Terraform configuration creates a Jenkins server on AWS EC2 with optional node/agent instances. The setup includes a custom VPC, security groups, and IAM roles for managing EKS clusters and Terraform state.

## Features

- **Jenkins Master Server**: Automatically installs and configures Jenkins on an Ubuntu EC2 instance
- **Optional Jenkins Nodes**: Create multiple Jenkins agent nodes to distribute build jobs
- **Custom VPC Setup**: Creates a VPC with public and private subnets
- **EKS IAM Role**: Dedicated IAM role for Jenkins nodes to manage EKS clusters
- **S3 and DynamoDB Access**: IAM permissions for using Terraform state backends
- **IAM Role Integration**: Use existing IAM roles or create new ones
- **Multiple OS Options**: Choose between Ubuntu or Amazon Linux 2 for the nodes
- **EKS Management Tools**: Nodes come pre-installed with Terraform, AWS CLI, kubectl, Helm, and other tools for managing EKS clusters
- **Email Notifications**: Security group configured for SMTP(25) and SMTPS(465) for email alerts

## Prerequisites

- **Terraform** version 1.9 or later
- An active **AWS account** with permissions to create EC2 instances, VPCs, and associated resources
- AWS CLI installed and configured with your credentials
- SSH key pair in AWS for connecting to instances

## Usage

### 1. Configure Your Variables

Create a `terraform.tfvars` file based on the example provided:

```hcl
# Region
my_region = "us-east-1"

# EC2 Instance
instance_type            = "t2.large"
key_name                 = "your-key-name"
my_ec2_name              = "Jenkins"
associate_pub_ip_address = true

# Jenkins Node/Slave Configuration
create_jenkins_node        = true   # Set to true to create Jenkins nodes
jenkins_node_count         = 2      # Number of Jenkins nodes to create
jenkins_node_instance_type = "t3.large"
jenkins_node_name          = "Jenkins-Node"
use_aws_linux_ami          = false  # Set to true to use Amazon Linux 2 instead of Ubuntu
install_terraform_aws      = true   # Set to true to install Terraform, AWS CLI, Helm, etc.

# EKS IAM Role Configuration
create_eks_iam_role       = true    # Set to true to create a new IAM role for EKS management
existing_eks_iam_role_name = ""     # Name of an existing role to use if not creating a new one
personal_aws_account_id   = "123456789012"  # Your personal AWS account ID
personal_user_name        = "your-username" # Your personal IAM user name
enable_full_s3_access     = false   # Set to true for full S3 access (not just Terraform state buckets)

# VPC
vpc_owner              = "YourName"
vpc_use                = "Jenkins"
vpc_cidr               = "10.0.0.0/16"
vpc_availability_zones = ["us-east-1a", "us-east-1b"]
vpc_public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true

# IAM - Existing Role Names (optional)
jenkins_master_iam_role_name = "your-existing-jenkins-master-role"
jenkins_node_iam_role_name = "your-existing-jenkins-node-role"
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. Accessing Jenkins

After the infrastructure is created, Terraform will output the following:

- **Jenkins URL**: The URL to access the Jenkins web UI
- **SSH Commands**: Commands to SSH into the Jenkins master and node instances
- **IP Addresses**: Public and private IPs of all instances

The Jenkins initial admin password can be found on the server by running:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 4. Configuring Jenkins Nodes

To add the created nodes to your Jenkins master:

1. Navigate to "Manage Jenkins" > "Manage Nodes and Clouds" > "New Node"
2. Enter a name for the node and select "Permanent Agent"
3. Configure the node with the following settings:
   - **Remote root directory**: `/home/ubuntu/jenkins-agent` (or `/home/ec2-user/jenkins-agent` for Amazon Linux)
   - **Launch method**: Launch agent via SSH
   - **Host**: Use the private IP of the node
   - **Credentials**: Add SSH credentials with your private key
   - **Host Key Verification Strategy**: Non-verifying

## Managing EKS Clusters

The Jenkins nodes come pre-installed with the following tools:

- **Terraform**: For infrastructure as code
- **AWS CLI**: For AWS resource management
- **kubectl**: For Kubernetes cluster management
- **Helm**: For Kubernetes package management
- **eksctl**: For EKS-specific operations

### EKS IAM Role Features

This configuration includes a dedicated IAM role for EKS management that provides:

1. **Dual Trust Policy**: Allows both Jenkins EC2 instances and your personal IAM user to assume the role
2. **EKS Management Permissions**: Includes AWS managed policies for EKS cluster and worker node management
3. **S3 and DynamoDB Access**: Permissions for Terraform backend state management
4. **Flexible Configuration**: Options to create a new role or use an existing one

### Using the EKS Role from Your Personal Account

To assume the EKS role from your personal AWS account:

```bash
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT_ID:role/eks-management-role --role-session-name eks-session
```

### Using Terraform with S3 Backend

The EKS role includes permissions for Terraform to use S3 backends. Example configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "your-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
```

### Service Limits and EKS

When creating EKS clusters, be aware of your AWS account's service limits, particularly vCPU limits. If you encounter `VcpuLimitExceeded` errors, you'll need to request a limit increase through AWS Service Quotas.

## Customization

### IAM Roles

You have several options for IAM roles:

1. **Create a new EKS IAM role**: Set `create_eks_iam_role = true`
2. **Use an existing EKS role**: Set `create_eks_iam_role = false` and provide `existing_eks_iam_role_name`
3. **Use existing Jenkins roles**: Provide `jenkins_master_iam_role_name` and/or `jenkins_node_iam_role_name`

### S3 Access Options

For S3 access, you can choose between:

1. **Limited S3 access for Terraform state**: Default option (`enable_full_s3_access = false`)
2. **Full S3 access**: Set `enable_full_s3_access = true` to attach the AmazonS3FullAccess policy

### Multiple Nodes

You can create multiple Jenkins nodes with identical configuration:

1. Set `create_jenkins_node = true`
2. Set `jenkins_node_count` to the number of nodes you want
3. Nodes will be named sequentially (e.g., Jenkins-Node-1, Jenkins-Node-2)

### Operating System

For Jenkins nodes, you can choose between:

- **Ubuntu** (default): Set `use_aws_linux_ami = false`
- **Amazon Linux 2**: Set `use_aws_linux_ami = true`

## Outputs

After running `terraform apply`, you'll see outputs including:

- Jenkins master details (ID, IP addresses, URL)
- SSH commands to connect to all instances
- Jenkins nodes details (if created)
- IAM instance profile information (if applicable)
- EKS management role name and ARN (if created)

## Security Considerations

- The security group allows traffic on ports:
  - 22 (SSH): For remote access
  - 80 (HTTP): For web access
  - 465 (SMTPS): For secure email notifications
  - 25 (SMTP): For email notifications
  - 8080 (Jenkins): For Jenkins web interface
  - 50000 (Jenkins agents): For Jenkins agent connections
- For production use, consider restricting these ports to specific IPs
- Use IAM roles with the principle of least privilege
- Regularly update the instances and Jenkins for security patches

## License

This project is licensed under the MIT License.

## Contact

For questions or feedback, please contact [JoeUzo](https://github.com/JoeUzo).
