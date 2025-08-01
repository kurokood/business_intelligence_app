# Business Intelligence Application - Serverless Architecture

A complete **serverless clickstream data processing pipeline** built with Terraform for business intelligence analytics.

## 🏗️ Architecture Overview

This serverless solution automatically generates, processes, and analyzes clickstream data:

- **Lambda**: Generates synthetic clickstream events every 5 minutes
- **EventBridge**: Schedules automatic data generation
- **S3**: Stores raw data, processed results, and job scripts
- **Glue**: ETL processing with database and table management
- **IAM**: Secure role-based access control
- **SSM**: Configuration parameter management
- **API Gateway**: Manual trigger endpoint (optional)

## 📁 Project Structure

```
business_intelligence_app/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions with defaults
├── outputs.tf                 # Output definitions
├── README.md                  # This documentation
├── aux/                       # Glue job files
│   ├── job.py                 # ETL processing script
│   └── countries_continents.csv # Geographic reference data
├── lambda_src/                # Lambda function source
│   └── lambda_function.py     # Data generator function
└── modules/                   # Terraform modules
    ├── lambda/                # Lambda function and scheduling
    ├── s3/                    # S3 bucket with security
    ├── iam/                   # IAM roles and policies
    ├── ssm/                   # Parameter store
    └── glue/                  # Database, table, and ETL job
```

## 🚀 Quick Start

### Prerequisites
- **Terraform** >= 1.0
- **AWS CLI** configured with appropriate permissions
- **AWS Account** with permissions for Lambda, S3, Glue, IAM

### Deployment
```bash
# 1. Initialize Terraform
terraform init

# 2. Review planned changes
terraform plan

# 3. Deploy infrastructure
terraform apply

# 4. Confirm with 'yes'
```

### Verification
```bash
# Check if Lambda is generating data
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/raw/

# View Lambda logs
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --follow
```

## 📊 Data Processing Workflow

### 1. **Automatic Data Generation**
- Lambda runs every 5 minutes (configurable)
- Generates 20 clickstream events per execution
- Stores JSON files in S3 `/raw/` folder

### 2. **ETL Processing**
```bash
# Run Glue job to process raw data
aws glue start-job-run --job-name $(terraform output -raw glue_job_name)
```

### 3. **Data Analysis**
- Set Athena query result location: `s3://your-bucket/athena-results/`
- Query processed data: `SELECT * FROM clickstream_db.clickstream_table`

## 🔧 Configuration

### Default Settings
- **Region**: us-east-1
- **Schedule**: Every 5 minutes
- **Events per run**: 20
- **Environment**: dev

### Customization
Override defaults using Terraform variables:
```bash
terraform apply -var="lambda_schedule=rate(10 minutes)" -var="events_per_execution=50"
```

## 📈 Data Flow

```
Lambda (every 5 min) → S3 /raw/ → Glue ETL → S3 /results/ → Athena Analytics
                                      ↓
                                 S3 /processed/ (archived)
```

## 🔍 Sample Analytics Queries

```sql
-- Event distribution by country
SELECT 
    "country-name",
    COUNT(*) as event_count,
    AVG(user_age) as avg_age
FROM clickstream_db.clickstream_table 
GROUP BY "country-name"
ORDER BY event_count DESC;

-- Product category analysis
SELECT 
    event_type,
    product_category,
    COUNT(*) as count
FROM clickstream_db.clickstream_table 
WHERE product_category IS NOT NULL
GROUP BY event_type, product_category
ORDER BY count DESC;
```

## 💰 Cost Optimization

This serverless architecture provides significant cost savings:
- **Lambda**: ~$0.20/month (vs $25/month for EC2)
- **S3**: ~$0.50/month for storage
- **Glue**: Pay-per-job execution
- **Total**: ~$1/month vs $30+/month for server-based solution

## 🛠️ Management Commands

### Manual Data Generation
```bash
# Trigger via API Gateway
curl -X POST $(terraform output -raw api_gateway_url)

# Direct Lambda invocation
aws lambda invoke --function-name $(terraform output -raw lambda_function_name) response.json
```

### Monitoring
```bash
# Lambda execution metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=$(terraform output -raw lambda_function_name) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

### Data Management
```bash
# Check data generation
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/raw/ --recursive | tail -10

# Check processed results
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/results/ --recursive

# Check archived data
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/processed/ --recursive
```

## 🔒 Security Features

- **IAM Least Privilege**: Minimal required permissions
- **S3 Security**: Public access blocked, encryption enabled
- **No Public Resources**: All resources in private AWS network
- **Versioning**: S3 bucket versioning enabled
- **Logging**: CloudWatch logs for all components

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy
```

## 🚨 Troubleshooting

### Lambda Not Running
```bash
# Check EventBridge rule
aws events list-rules --name-prefix "bi-app-serverless"

# Check Lambda errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/$(terraform output -raw lambda_function_name) \
  --filter-pattern "ERROR"
```

### Glue Job Issues
```bash
# Check job status
aws glue get-job-runs --job-name $(terraform output -raw glue_job_name) --max-items 1

# View job logs in CloudWatch
```

### No Data in S3
- Verify Lambda has S3 permissions
- Check Lambda execution logs
- Confirm EventBridge rule is enabled

## 📋 Architecture Benefits

✅ **Serverless**: No infrastructure management  
✅ **Cost-Effective**: Pay only for usage  
✅ **Scalable**: Automatic scaling  
✅ **Reliable**: Multi-AZ deployment  
✅ **Secure**: AWS security best practices  
✅ **Maintainable**: Infrastructure as Code  

This solution provides a production-ready, cost-effective platform for clickstream analytics and business intelligence.