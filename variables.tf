# Serverless Architecture Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Removed EC2-specific variables:
# - instance_type (not needed for Lambda)
# - ami_id (not needed for Lambda)  
# - git_repo_url (files uploaded via Terraform)

# Lambda-specific variables (optional customization)
variable "lambda_schedule" {
  description = "EventBridge schedule expression for Lambda"
  type        = string
  default     = "rate(5 minutes)"
}

variable "events_per_execution" {
  description = "Number of events to generate per Lambda execution"
  type        = number
  default     = 20
}