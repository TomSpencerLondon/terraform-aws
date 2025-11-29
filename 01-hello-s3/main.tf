# ============================================================
# EXERCISE 01: Hello S3
# Your first Terraform configuration!
# ============================================================

# ------------------------------------------------------------
# TERRAFORM SETTINGS
# Specifies required providers and their versions
# ------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------
# PROVIDER CONFIGURATION
# Tells Terraform how to connect to AWS (or LocalStack)
# ------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  # LocalStack configuration
  access_key = "test"
  secret_key = "test"

  # Skip AWS-specific validation (not needed for LocalStack)
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Point all services to LocalStack
  endpoints {
    s3 = var.localstack_endpoint
  }

  # Required for S3 path-style access in LocalStack
  s3_use_path_style = true
}

# ------------------------------------------------------------
# S3 BUCKET RESOURCE
# This creates an S3 bucket in LocalStack
# ------------------------------------------------------------
resource "aws_s3_bucket" "hello_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My First Terraform Bucket"
    Environment = "learning"
    Exercise    = "01-hello-s3"
  }
}

# ------------------------------------------------------------
# OUTPUTS
# Values displayed after terraform apply
# ------------------------------------------------------------
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.hello_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.hello_bucket.arn
}

output "bucket_region" {
  description = "The region of the S3 bucket"
  value       = aws_s3_bucket.hello_bucket.region
}
