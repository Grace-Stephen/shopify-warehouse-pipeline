variable "project_prefix" {}

variable "aws_region" {}

variable "scripts_bucket" {
  description = "S3 bucket for Glue scripts"
}

variable "raw_bucket" {
  description = "Raw S3 bucket containing ingested Shopify data"
}

variable "glue_role_arn" {
  description = "IAM role for Glue service"
}

variable "redshift_workgroup" {
  description = "Redshift Serverless workgroup name"
}

variable "redshift_namespace" {
  description = "Redshift namespace for Glue connection"
  type        = string
}

variable "redshift_db" {
  description = "Target Redshift database name"
  type    = string
  default = "dev"
}

variable "redshift_table" {
  description = "Target Redshift table name for transformed data"
}

variable "redshift_admin_username" { type = string }
variable "redshift_admin_password" { type = string }
variable "redshift_endpoint" { type = string }

variable "private_subnet_1_id" {
  type = string
}

variable "private_subnet_1_az" {
  type = string
}

variable "redshift_sg_id" {
  type = string
}

variable "redshift_port" {
  type    = number
  default = 5439
}

variable "eventbridge_role_arn" {
  description = "ARN of the EventBridge role that triggers Glue"
  type        = string
}

variable "eventbridge_role" {
  description = "the EventBridge role that triggers Glue"
  type        = string
}

variable "glue_security_group_ids" {
  description = "List of security groups for the Glue job connection"
  type        = list(string)
}

# variable "eventbridge_role_dependencies" {
#   type = list(any)
# }



