
# Terraform AWS EC2 Instance with EBS Lifecycle

This repository contains Terraform configurations to create an AWS EC2 instance with EBS lifecycle management. The setup includes creating a VPC, a public subnet, a security group, and an EC2 instance with a root EBS volume.

## Architecture

The architecture of the infrastructure is as follows:

1. **VPC (Virtual Private Cloud)**:
   - A VPC is created with a specified CIDR block.

2. **Subnet**:
   - A public subnet is created within the VPC, with a specified CIDR block and availability zone.
   - The subnet is configured to map public IPs on launch.

3. **Security Group**:
   - A security group is created to allow SSH traffic (port 22) from any IP address (0.0.0.0/0).
   - The security group also allows all outbound traffic.

4. **EC2 Instance**:
   - An EC2 instance is created using the most recent Amazon Linux 2 AMI.
   - The instance type is specified by a variable.
   - The instance is launched in the public subnet.
   - The instance is associated with the created security group.
   - The root block device is configured with a specified volume size and type.
   - Lifecycle configuration is set to create the instance before destroying the old one and to ignore changes to the AMI.

5. **Example in Test Folder**:
    The example in the test folder uses the AWS EC2 module to create instances. It demonstrates how to use the module to create an EC2 instance with the specified configuration.

    **Usage**:
    - Navigate to the test folder:
        cd test
    - Initialize Terraform:
        terraform init
    - Apply the configuration:
        terraform apply
