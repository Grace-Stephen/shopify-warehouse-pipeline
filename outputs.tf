# --- S3 Outputs ---
output "raw_bucket_name" {
  value = module.s3.raw_bucket_name
}

output "raw_bucket_arn" {
  value = module.s3.raw_bucket_arn
}

output "glue_scripts_bucket_name" {
  value = module.s3.glue_scripts_bucket_name
}

output "glue_scripts_bucket_arn" {
  value = module.s3.glue_scripts_bucket_arn
}

# --- IAM Outputs ---
output "glue_role_arn" {
  value = module.iam.glue_role_arn
}

output "lambda_role_arn" {
  value = module.iam.lambda_role_arn
}

output "eventbridge_role_arn" {
  value = module.iam.eventbridge_role_arn
}

#RedShift Output
output "redshift_endpoint" {
  value = module.redshift.redshift_endpoint
}

#Lambda Output
output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

