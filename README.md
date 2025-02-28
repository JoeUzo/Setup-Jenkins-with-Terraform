
# Setup Jenkins with Terraform

This repository provides Terraform code to provision a fully functional Jenkins server on AWS using EC2 and a dedicated VPC. The setup leverages Terraform modules for a modular, scalable, and reproducible infrastructure deployment.

## Features

- **Jenkins on AWS EC2:** Automatically installs and configures Jenkins on an Ubuntu EC2 instance.
- **Custom VPC Setup:** Uses a Terraform module in the `vpc/` subfolder to create a VPC with public and private subnets.
- **Security Groups:** Configures security groups to allow necessary traffic for Jenkins (port 8080 for the web UI, port 50000 for agent communications, and SSH on port 22).
- **Modular & Maintainable:** Splits infrastructure into reusable modules for easier maintenance and upgrades.
- **Remote State Support:** Option to use remote state management (e.g., S3 backend) for state locking and consistency.

## Prerequisites

- **Terraform** version 1.9 or later
- An active **AWS account** with permissions to create EC2 instances, VPCs, and associated resources
- AWS CLI installed and configured with your credentials
- Basic knowledge of AWS, Jenkins, and Terraform

## Repository Structure

```
.
├── main.tf             # Main Terraform configuration for the Jenkins EC2 instance
├── outputs.tf          # Outputs for the Jenkins instance (ID, public IP)
├── variables.tf        # Variable definitions for configuration
├── terraform.tfvars    # Example variable values (do not commit sensitive info)
└── vpc/                # Subfolder containing the VPC module configuration
    ├── main.tf         # VPC module code to set up networking resources
    └── outputs.tf      # VPC outputs (e.g., VPC ID, subnet IDs)
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/JoeUzo/Setup-Jenkins-with-Terraform.git
cd Setup-Jenkins-with-Terraform
```

### 2. Configure Your Environment

- Update `terraform.tfvars` with your specific AWS region, VPC settings, and other parameters.
- If using a remote backend for state management, update the backend configuration accordingly.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview the Infrastructure Changes

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply -auto-approve
```

## Jenkins Configuration

The EC2 instance user data script is tailored for Ubuntu:

- Updates the system packages.
- Installs OpenJDK 11 (a prerequisite for Jenkins).
- Adds the official Jenkins repository.
- Installs and starts Jenkins.
- Prints the initial admin password to help you complete the Jenkins setup via the web UI.

Once deployed, access Jenkins at `http://<EC2_PUBLIC_IP>:8080`.

## Customization

- **EC2 Instance:** Adjust the AMI ID, instance type, and key name in `main.tf` to match your requirements.
- **User Data Script:** Modify the installation script if you need a different Jenkins version or custom configuration.
- **VPC Module:** Tweak the VPC settings (e.g., CIDR, subnets, NAT gateway options) in the `vpc/` folder.

## Security Considerations

- **State Files:** Ensure that your Terraform state files (especially if containing sensitive outputs) are stored securely. Use remote backends with proper access control.
- **Security Groups:** Customize the security group rules to restrict access to your instance as needed. Avoid opening ports globally unless necessary.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to enhance this setup.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

For questions or feedback, please contact [JoeUzo](https://github.com/JoeUzo).
