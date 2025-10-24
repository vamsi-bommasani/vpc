output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_az1" {
  description = "Public subnet ID AZ1"
  value       = aws_subnet.public_subnet_az1.id
}

output "public_subnet_az2" {
  description = "Public subnet ID AZ2"
  value       = aws_subnet.public_subnet_az2.id
}

output "public_subnet_az3" {
  description = "Public subnet ID AZ3"
  value       = aws_subnet.public_subnet_az3.id
}

output "private_subnet_az1" {
  description = "Private subnet ID AZ1"
  value       = aws_subnet.private_subnet_az1.id
}

output "private_subnet_az2" {
  description = "Private subnet ID AZ2"
  value       = aws_subnet.private_subnet_az2.id
}

output "private_subnet_az3" {
  description = "Private subnet ID AZ3"
  value       = aws_subnet.private_subnet_az3.id
}
