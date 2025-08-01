# IAM Module Outputs
# EC2 outputs removed - using serverless architecture

output "glue_job_role_arn" {
  description = "ARN of the Glue job role"
  value       = aws_iam_role.glue_job_role.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}