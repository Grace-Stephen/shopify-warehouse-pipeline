data "aws_caller_identity" "current" {}

# CloudTrail trail to capture S3 data events
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_prefix}-trail"
  s3_bucket_name                = var.cloudtrail_logs_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  event_selector {
    read_write_type           = "All" # captures PutObject
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.raw_bucket_name}/*"]
    }
  }
}
