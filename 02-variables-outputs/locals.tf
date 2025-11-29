# ============================================================
# LOCALS
# Computed values derived from variables
# ============================================================

locals {
  # Combine project name and environment for resource naming
  # Example: "terraform-learning-dev"
  name_prefix = "${var.project_name}-${var.environment}"

  # Environment-specific settings
  is_production = var.environment == "prod"

  # Merge common tags with environment tag
  default_tags = merge(var.common_tags, {
    Environment = var.environment
  })

  # Build the full list of bucket names with prefix
  # Example: ["terraform-learning-dev-logs", "terraform-learning-dev-data", ...]
  bucket_names = [for suffix in var.bucket_suffixes : "${local.name_prefix}-${suffix}"]

  # Filter buckets that have versioning enabled
  versioned_buckets = {
    for name, config in var.buckets : name => config
    if config.versioning
  }

  # Count of versioned vs non-versioned buckets
  versioned_count     = length(local.versioned_buckets)
  non_versioned_count = length(var.buckets) - local.versioned_count

  # Timestamp for unique naming (useful for testing)
  # Note: This changes on every apply - use carefully!
  # timestamp_suffix = formatdate("YYYYMMDDhhmmss", timestamp())
}
