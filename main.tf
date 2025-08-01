# Business Intelligence Application - Serverless Architecture
# This version eliminates EC2, VPC, and Security Groups entirely

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  project_name = "bi-app-serverless"
  common_tags = {
    Project      = "Business Intelligence App - Serverless"
    Environment  = var.environment
    ManagedBy    = "Terraform"
    Architecture = "Serverless"
  }
}

# S3 Module - Same as before
module "s3" {
  source = "./modules/s3"

  bucket_name = "${local.project_name}-${random_string.suffix.result}"
  common_tags = local.common_tags
}

# IAM Module - Updated with Lambda role
module "iam" {
  source = "./modules/iam"

  s3_bucket_arn = module.s3.bucket_arn
  project_name  = local.project_name
  common_tags   = local.common_tags
}

# SSM Module - Same as before
module "ssm" {
  source = "./modules/ssm"

  bucket_name = module.s3.bucket_name
  common_tags = local.common_tags
}

# Glue Module - Same as before
module "glue" {
  source = "./modules/glue"

  s3_bucket_name = module.s3.bucket_name
  glue_role_arn  = module.iam.glue_job_role_arn
  common_tags    = local.common_tags
}

# Lambda Module - Replaces EC2, VPC, and Security Groups
module "lambda" {
  source = "./modules/lambda"

  project_name         = local.project_name
  s3_bucket_name       = module.s3.bucket_name
  lambda_role_arn      = module.iam.lambda_execution_role_arn
  ssm_parameter_name   = "clickstream_bucket"
  lambda_schedule      = var.lambda_schedule
  events_per_execution = var.events_per_execution
  common_tags          = local.common_tags
}

# Optional: API Gateway for manual triggering (bonus feature)
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "${local.project_name}-api"
  description = "API to manually trigger clickstream generation"

  tags = local.common_tags
}

resource "aws_api_gateway_resource" "generate" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "generate"
}

resource "aws_api_gateway_method" "generate_post" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.generate.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.generate.id
  http_method = aws_api_gateway_method.generate_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambda.function_arn}/invocations"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "lambda_api" {
  depends_on = [
    aws_api_gateway_method.generate_post,
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.lambda_api.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "prod"

  tags = local.common_tags
}
