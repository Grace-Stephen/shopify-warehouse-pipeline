# variable "project_prefix" {}
# variable "vpc_id" {}
# variable "private_subnet_ids" {
#   type = list(string)
# }
# # variable "glue_sg_id" {}
# variable "db_name" {
#   default = "shopify_dw"
# }
# variable "master_username" {
#   description = "Redshift admin username"
#   type        = string
# }
# variable "master_password" {
#   description = "Redshift admin password"
#   type        = string
#   sensitive   = true
# }
# variable "redshift_role_arn" {}

#VARIABLE FOR REDSHIFT SERVERLESS
variable "project_prefix" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "redshift_role_arn" {
  description = "IAM role ARN for redshift"
  type        = string
}

variable "admin_username" {
  description = "Redshift admin username"
  type        = string
}
variable "master_password" {
  description = "Redshift admin password"
  type        = string
  sensitive   = true
}
