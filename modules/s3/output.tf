output "raw_bucket_name" {
  value = aws_s3_bucket.raw_data.bucket
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.raw_data.arn
}

output "glue_scripts_bucket_name" {
  value = aws_s3_bucket.glue_scripts.bucket
}

output "glue_scripts_bucket_arn" {
  value = aws_s3_bucket.glue_scripts.arn
}

output "cloudtrail_logs_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs.bucket
}

output "lambda_artifacts_bucket_name" {
  value = aws_s3_bucket.lambda_artifacts.bucket
}
