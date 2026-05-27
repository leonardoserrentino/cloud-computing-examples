variable "aws_region" {
  description = "AWS Region to execute deploy in"
  type        = string
  default     = "eu-south-1"
}

variable "environment" {
  description = "Environment name (dev, prod, ...)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Classless Inter-Domain Routing for VPC"
  type        = string
  default     = "10.0.0.0/16" # Up to 65,536 IP addresses
}
