# S3 Module

# S3 Bucket
resource "aws_s3_bucket" "clickstream" {
  bucket = var.bucket_name

  tags = merge(var.common_tags, {
    Name = "Clickstream Data Bucket"
  })
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "clickstream" {
  bucket = aws_s3_bucket.clickstream.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "clickstream" {
  bucket = aws_s3_bucket.clickstream.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "clickstream" {
  bucket = aws_s3_bucket.clickstream.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}