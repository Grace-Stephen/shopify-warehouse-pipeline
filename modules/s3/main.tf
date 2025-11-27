###########################################
# Raw Data Bucket - for Shopify API dumps
###########################################

resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_prefix}-raw-data"

  force_destroy = true

  tags = {
    Project = var.project_prefix
    Purpose = "Shopify Raw Data Storage"
  }
}

# # Allow S3 to send events to EventBridge
# resource "aws_s3_bucket_notification" "raw_data_events" {
#   bucket = aws_s3_bucket.raw_data.id
#   eventbridge = true
# }

# Enable versioning for data traceability
resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

###########################################
# Glue Scripts Bucket - store ETL scripts
###########################################

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project_prefix}-glue-scripts"

  force_destroy = true

  tags = {
    Project = var.project_prefix
    Purpose = "Glue ETL Scripts Storage"
  }
}

# Enable versioning for scripts too
resource "aws_s3_bucket_versioning" "glue_scripts_versioning" {
  bucket = aws_s3_bucket.glue_scripts.id

  versioning_configuration {
    status = "Enabled"
  }
}

#S3 BUCKET FOR CLOUDTRAIL LOGS
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_prefix}-cloudtrail-logs"
  force_destroy = true
}

###########################################
# Lambda Artifacts Bucket - store ZIP packages
###########################################

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "${var.project_prefix}-lambda-artifacts"

  force_destroy = true

  tags = {
    Project = var.project_prefix
    Purpose = "Lambda Deployment Artifacts"
  }
}

# Enable versioning for rollback capability
resource "aws_s3_bucket_versioning" "lambda_artifacts_versioning" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}
