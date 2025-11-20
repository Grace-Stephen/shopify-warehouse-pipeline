data "aws_caller_identity" "current" {}

# EventBridge Rule 1: Trigger Lambda every hour to fetch data
resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name                = "${var.project_prefix}-lambda-schedule"
  description         = "Trigger Lambda every twenty four hours to fetch data"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name
  target_id = "lambda-function"
  arn       = var.lambda_function_arn
}

# --- S3 -> EventBridge -> Glue Workflow ---

# --- Rule: Trigger Glue Workflow when new data lands in S3 ---
resource "aws_cloudwatch_event_rule" "glue_trigger_rule" {
  name        = "${var.project_prefix}-glue_trigger_rule"
  description = "Trigger Glue workflow when new data lands in S3 raw bucket"

  event_pattern = jsonencode({
    "source" = ["aws.s3"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    "detail" = {
      "eventSource" = ["s3.amazonaws.com"],
      "eventName"   = ["PutObject", "CompleteMultipartUpload"],
      "requestParameters" = {
        "bucketName" = [var.raw_bucket_name]
      }
    }
  })
}

# EventBridge target to start Glue workflow
resource "aws_cloudwatch_event_target" "glue_workflow_target" {
  rule      = aws_cloudwatch_event_rule.glue_trigger_rule.name
  target_id = "glue-workflow-trigger"
  arn       = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:workflow/${var.project_prefix}-workflow"
  role_arn  = var.eventbridge_role_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}



