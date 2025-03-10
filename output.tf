output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "The ID of the instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP address"
  value       = aws_instance.this.public_ip
}