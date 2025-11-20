resource "aws_lambda_function" "shopify_user_data" {
  function_name = "${var.project_prefix}-shopify-user-data"
  role          = var.lambda_role_arn
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  # filename      = "${path.root}/lambda_code_v2.zip"
#in place of filename for cicd workflow
  s3_bucket     = var.lambda_artifacts_bucket
  s3_key        = var.lambda_zip_key

  environment {
    variables = {
      RAW_BUCKET = var.raw_bucket_name
    }
  }
}


