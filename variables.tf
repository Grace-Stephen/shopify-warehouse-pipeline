variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "ogoma"
}

variable "admin_username" {
  description = "Redshift admin username"
  type        = string
}

variable "master_password" {
  description = "Redshift master password"
  type        = string
  sensitive   = true
}

variable "lambda_zip_key" {
  type = string
  default = "lambda.zip"
}

