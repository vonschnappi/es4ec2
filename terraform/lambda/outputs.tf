output "lambda_name" {
  value = aws_lambda_function.ec2_state_change_to_es.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.ec2_state_change_to_es.arn
}
