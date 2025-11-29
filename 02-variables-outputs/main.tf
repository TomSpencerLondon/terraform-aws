# ============================================================
# EXERCISE 02: Variables & Outputs
# Deep dive into variable types and creating multiple resources
# ============================================================

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
# ------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = var.localstack_endpoint
  }

  s3_use_path_style = true
}

# ------------------------------------------------------------
# METHOD 1: Using for_each with a map
# Creates buckets from the var.buckets map
# This is the PREFERRED approach for named resources
# ------------------------------------------------------------
resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets

  # each.key = "logs", "data", or "backup"
  # each.value = the object { versioning = bool, tags = map }
  bucket = "${local.name_prefix}-${each.key}"

  # Merge default tags with bucket-specific tags
  tags = merge(local.default_tags, each.value.tags, {
    BucketType = each.key
  })
}

# ------------------------------------------------------------
# VERSIONING CONFIGURATION
# Only applied to buckets where versioning = true
# Uses filtering in for_each
# ------------------------------------------------------------
resource "aws_s3_bucket_versioning" "buckets" {
  # Only create versioning for buckets that want it
  for_each = local.versioned_buckets

  # Reference the bucket we created above
  bucket = aws_s3_bucket.buckets[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------
# METHOD 2: Using count with a list
# Creates buckets from var.bucket_suffixes list
# Useful when you just need numbered/indexed resources
# ------------------------------------------------------------
resource "aws_s3_bucket" "counted_buckets" {
  count = length(var.bucket_suffixes)

  # count.index = 0, 1, 2, ...
  # Using element() to get the value at that index
  bucket = "${local.name_prefix}-counted-${var.bucket_suffixes[count.index]}"

  tags = merge(local.default_tags, {
    Method = "count"
    Index  = count.index
  })
}

# ------------------------------------------------------------
# CONDITIONAL RESOURCE
# Only created when environment is "prod"
# Demonstrates: count with boolean condition
# ------------------------------------------------------------
resource "aws_s3_bucket" "prod_archive" {
  # This creates 1 bucket if prod, 0 buckets otherwise
  count = local.is_production ? 1 : 0

  bucket = "${local.name_prefix}-archive"

  tags = merge(local.default_tags, {
    Purpose = "Production archive storage"
  })
}
