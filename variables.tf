# ======================================================
# AWS
# ======================================================

variable "aws_region" {
  description = "provide the aws_region"
  type        = string
}

# ======================================================
# Tags
# ======================================================

variable "app_id" {
  description = "provide an app-id"
  type        = string
}

variable "environment" {
  description = "provide some environment name"
  type        = string
}

variable "notification_mail" {
  description = "provide an engineer email to send mails"
  type        = string
}

# ======================================================
# VPC
# ======================================================

variable "vpc_cidr" {
  type        = string
  description = "CIDR value for VPC"
}

variable "public_subnet_az1" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "public_subnet_az2" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "public_subnet_az3" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_az1" {
  type        = list(string)
  description = "private Subnet CIDR values"
}

variable "private_subnet_az2" {
  type        = list(string)
  description = "private Subnet CIDR values"
}

variable "private_subnet_az3" {
  type        = list(string)
  description = "private Subnet CIDR values"
}
