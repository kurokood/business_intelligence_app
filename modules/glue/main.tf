# Glue Module

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Glue Database
resource "aws_glue_catalog_database" "clickstream_db" {
  name        = "clickstream_db"
  catalog_id  = data.aws_caller_identity.current.account_id
  description = "Database for clickstream data"

  tags = var.common_tags
}

# Glue Table
resource "aws_glue_catalog_table" "clickstream_table" {
  name          = "clickstream_table"
  database_name = aws_glue_catalog_database.clickstream_db.name
  catalog_id    = data.aws_caller_identity.current.account_id
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "1"
    "classification"         = "csv"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/results/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "user_age"
      type = "bigint"
    }

    columns {
      name = "continent"
      type = "string"
    }

    columns {
      name = "country-name"
      type = "string"
    }

    columns {
      name = "user_action"
      type = "string"
    }

    columns {
      name = "product_category"
      type = "string"
    }

    columns {
      name = "event_type"
      type = "string"
    }

    columns {
      name = "click-date"
      type = "string"
    }

    columns {
      name = "user_id"
      type = "string"
    }
  }
}

# Glue Job
resource "aws_glue_job" "clickstream_job" {
  name         = "clickstream-gluejob"
  role_arn     = var.glue_role_arn
  glue_version = "4.0"
  max_retries  = 0
  timeout      = 2880

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/glue-script/job.py"
  }

  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-disable"
  }

  tags = merge(var.common_tags, {
    Name = "Clickstream Processing Job"
  })
}