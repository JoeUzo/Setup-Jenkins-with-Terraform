# Jenkins on AWS with Terraform

This Terraform configuration creates a Jenkins server on AWS EC2 with optional node/agent instances. The setup includes a custom VPC, security groups, and optional IAM roles.

## Features

- **Jenkins Master Server**: Automatically installs and configures Jenkins on an Ubuntu EC2 instance
- **Optional Jenkins Nodes**: Create multiple Jenkins agent nodes to distribute build jobs
- **Custom VPC Setup**: Creates a VPC with public and private subnets
- **IAM Role Integration**: Use existing IAM roles for your instances
- **Multiple OS Options**: Choose between Ubuntu or Amazon Linux 2 for the nodes
- **EKS Management Tools**: Nodes come pre-installed with Terraform, AWS CLI, kubectl, Helm, and other tools for managing EKS clusters

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

To create an EKS cluster using Terraform:

1. SSH into one of the Jenkins nodes
2. Create a Terraform configuration for your EKS cluster
3. Run the standard Terraform workflow (init, plan, apply)
4. Use `aws eks update-kubeconfig` to configure kubectl to interact with your cluster

## Customization

### IAM Roles

This configuration doesn't create IAM roles but allows you to attach existing roles:

1. Create IAM roles in AWS with the permissions you need
2. Specify the role names in your `terraform.tfvars` file

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

## Security Considerations

- The security group allows traffic on ports 22 (SSH), 80 (HTTP), 8080 (Jenkins), and 50000 (Jenkins agents)
- For production use, consider restricting these ports to specific IPs
- Use IAM roles with the principle of least privilege
- Regularly update the instances and Jenkins for security patches

## License

This project is licensed under the MIT License.

## Contact

For questions or feedback, please contact [JoeUzo](https://github.com/JoeUzo).
