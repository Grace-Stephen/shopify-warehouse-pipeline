variable "project_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "raw_bucket_name" {
  description = "Raw data bucket name to track S3 object events"
  type        = string
}

variable "cloudtrail_logs_bucket_name" {
  description = "S3 bucket for storing CloudTrail logs"
  type        = string
}
