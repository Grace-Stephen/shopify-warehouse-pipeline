output "lambda_function_arn" {
  value = aws_lambda_function.shopify_user_data.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.shopify_user_data.function_name
}