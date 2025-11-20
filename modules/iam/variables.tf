variable "raw_bucket_arn" {
  description = "ARN of the raw S3 bucket"
  type        = string
}

variable "glue_scripts_bucket_arn" {
  description = "ARN of the Glue scripts S3 bucket"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "ogoma"
}

variable "cloudtrail_logs_bucket_name" {
  description = "Bucket where CloudTrail logs are stored"
  type        = string
}
