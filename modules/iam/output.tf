output "lambda_role_arn" {
value = aws_iam_role.lambda_role.arn
}

output "glue_role_arn" {
value = aws_iam_role.glue_role.arn
}

output "eventbridge_role_arn" {
  value = aws_iam_role.eventbridge_role.arn
}

output "redshift_role_arn" {
  value = aws_iam_role.redshift_role.arn
}

output "eventbridge_role" {
  value = aws_iam_role.eventbridge_role
}
