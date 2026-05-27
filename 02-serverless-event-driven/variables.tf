variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "eu-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
