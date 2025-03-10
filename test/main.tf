
  module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  tags = local.tags
}

data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = [
            "amzn2-ami-hvm-*-x86_64-gp2"
        ]
    }
}

module "ec2" {
    source = "github.com/akromah12/terraform-aws-ec2-instance.git"

    ami = data.aws_ami.amazon_linux_2.id
    instance_type = "t2.micro"
    availability_zone = element(module.vpc.azs, 0)
    subnet_id = element(module.vpc.public_subnets, 0)
    vpc_security_group_ids = [module.aws_security_group.security_group_id]

    root_block_device = [{
        volume_size = 8
        volume_type = "gp3"
    }]
}

module "aws_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>4.0.0"

  name = local.name
  vpc_id = module.vpc.vpc_id
  description = "Security group for the EC2 instance"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

}

output "this_security_group_id" {
  value = module.aws_security_group.security_group_id
}


