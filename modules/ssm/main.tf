# SSM Module

# SSM Parameter for S3 bucket name
resource "aws_ssm_parameter" "clickstream_bucket" {
  name  = "clickstream_bucket"
  type  = "String"
  value = var.bucket_name

  tags = merge(var.common_tags, {
    Name = "Clickstream Bucket Parameter"
  })
}