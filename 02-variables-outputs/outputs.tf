# ============================================================
# OUTPUTS
# Demonstrating various output expressions and formats
# ============================================================

# ------------------------------------------------------------
# SIMPLE OUTPUTS
# ------------------------------------------------------------

output "environment" {
  description = "Current deployment environment"
  value       = var.environment
}

output "name_prefix" {
  description = "Computed name prefix for all resources"
  value       = local.name_prefix
}

output "is_production" {
  description = "Whether this is a production environment"
  value       = local.is_production
}

# ------------------------------------------------------------
# COUNTS AND SUMMARIES
# ------------------------------------------------------------

output "total_buckets_created" {
  description = "Total number of buckets created"
  value       = length(aws_s3_bucket.buckets) + length(aws_s3_bucket.counted_buckets)
}

output "versioned_bucket_count" {
  description = "Number of buckets with versioning enabled"
  value       = local.versioned_count
}

# ------------------------------------------------------------
# LISTING OUTPUTS (from for_each resources)
# ------------------------------------------------------------

# List of bucket names
output "bucket_names" {
  description = "List of all bucket names (for_each method)"
  value       = [for b in aws_s3_bucket.buckets : b.id]
}

# Map of bucket name -> ARN
output "bucket_arns" {
  description = "Map of bucket names to ARNs"
  value       = { for k, b in aws_s3_bucket.buckets : k => b.arn }
}

# Map with multiple attributes
output "bucket_details" {
  description = "Detailed info about each bucket"
  value = {
    for k, b in aws_s3_bucket.buckets : k => {
      name   = b.id
      arn    = b.arn
      region = b.region
    }
  }
}

# ------------------------------------------------------------
# LISTING OUTPUTS (from count resources)
# ------------------------------------------------------------

output "counted_bucket_names" {
  description = "List of bucket names created with count"
  value       = aws_s3_bucket.counted_buckets[*].id
}

# Using splat expression [*] is shorthand for:
# [for b in aws_s3_bucket.counted_buckets : b.id]

# ------------------------------------------------------------
# FILTERED OUTPUTS
# ------------------------------------------------------------

output "versioned_buckets" {
  description = "Only buckets that have versioning enabled"
  value       = [for k, v in local.versioned_buckets : "${local.name_prefix}-${k}"]
}

# ------------------------------------------------------------
# CONDITIONAL OUTPUT
# ------------------------------------------------------------

output "prod_archive_bucket" {
  description = "Archive bucket (only exists in prod)"
  value       = local.is_production ? aws_s3_bucket.prod_archive[0].id : "N/A - only created in prod"
}

# ------------------------------------------------------------
# SENSITIVE OUTPUT
# Won't be shown in console, but accessible via terraform output
# ------------------------------------------------------------

output "bucket_access_example" {
  description = "Example showing sensitive value handling"
  value       = "Bucket secret suffix: ${var.secret_suffix}"
  sensitive   = true
}

# ------------------------------------------------------------
# JSON OUTPUT FOR SCRIPTS
# Run: terraform output -json bucket_summary
# ------------------------------------------------------------

output "bucket_summary" {
  description = "Summary suitable for JSON consumption"
  value = {
    environment         = var.environment
    total_buckets       = length(aws_s3_bucket.buckets)
    versioned_buckets   = local.versioned_count
    bucket_names        = [for b in aws_s3_bucket.buckets : b.id]
  }
}
