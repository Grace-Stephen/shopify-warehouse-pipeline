output "lambda_schedule_rule_arn" {
  description = "ARN of the EventBridge rule that triggers Lambda every hour"
  value       = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}

output "eventbridge_rule_arn" {
  value = aws_cloudwatch_event_rule.glue_trigger_rule.arn
}

output "eventbridge_rule_name" {
  value = aws_cloudwatch_event_rule.glue_trigger_rule.name
}

output "eventbridge_target_id" {
  value = aws_cloudwatch_event_target.glue_workflow_target.id
}

