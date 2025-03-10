

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type = string
  
}
variable "subnet_cidr_blocks" {
  description = "The CIDR blocks for the subnets"
  default     = "10.0.1.0/24"
  type = string
}
variable "availability_zones" {
  description = "The availability zones for the subnets"
  default     = ["us-east-1a", "us-east-1b"]
  type = list(string)
}

  
variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}
variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name for the AMI ID. For Amazon Linux AMI SSM parameters see [reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html)"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}
  

variable "ebs_size" {
    description = "The size of the EBS volume"
    type = number
    default = 8
  
}
variable "ebs_type" {
    description = "The type of the EBS volume"
    type = string
    default = "gp3"
  
}
  
variable "create_eip" {
  description = "Determines whether a public EIP will be created and associated with the instance."
  type        = bool
  default     = false
}