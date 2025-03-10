
data "aws_partition" "current" {}

locals {
  create = var.create 

 # Checks if the instance type is a T-series instance (e.g., t2, t3, t3a, t4g)
  is_t_instance_type = replace(var.instance_type, "/^t(2|3|3a|4g){1}\\..*$/", "1") == "1" ? true : false

  ami = try(coalesce(var.ami, try(nonsensitive(data.aws_ssm_parameter.this[0].value), null)), null)
}
# Fetches an SSM parameter if needed
data "aws_ssm_parameter" "this" {
  count = local.create && var.ami == null ? 1 : 0

  name = var.ami_ssm_parameter
}

# Fetches the most recent Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
# Only consider AMIs owned by Amazon
  owners = ["amazon"]
}

# Creates a VPC with the specified CIDR block
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

# Create a public subnet within the VPC
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr_blocks
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}


#Creates an EC2 instance
resource "aws_instance" "this" {
ami = data.aws_ami.amazon_linux.id
 instance_type = var.instance_type
 subnet_id = aws_subnet.public.id
 security_groups = [aws_security_group.this.id]
 

 # EBS block device configuration
 root_block_device {
    volume_size = var.ebs_size
    volume_type = var.ebs_type
  }

# Lifecycle configuration to manage resource creation and updates
lifecycle {
    create_before_destroy = true
    prevent_destroy = false
    ignore_changes = [ami]
}

}

# Creates a security group that allows SSH traffic
resource "aws_security_group" "this" {
  name = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
