# ============================================================
# VARIABLES
# Demonstrating all Terraform variable types
# ============================================================

# ------------------------------------------------------------
# BASIC TYPES
# ------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

# String with validation
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# String for naming
variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "terraform-learning"
}

# Number
variable "max_bucket_count" {
  description = "Maximum number of buckets allowed"
  type        = number
  default     = 10
}

# Boolean
variable "enable_versioning" {
  description = "Enable versioning on all buckets"
  type        = bool
  default     = true
}

# ------------------------------------------------------------
# COLLECTION TYPES
# ------------------------------------------------------------

# List of strings
variable "bucket_suffixes" {
  description = "List of bucket name suffixes to create"
  type        = list(string)
  default     = ["logs", "data", "backup"]
}

# Map of strings (for tags)
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "terraform-learning"
    ManagedBy = "terraform"
    Exercise  = "02-variables-outputs"
  }
}

# ------------------------------------------------------------
# COMPLEX TYPES
# ------------------------------------------------------------

# Map of objects - each bucket has its own configuration
variable "buckets" {
  description = "Map of bucket configurations"
  type = map(object({
    versioning = bool
    tags       = map(string)
  }))
  default = {
    logs = {
      versioning = false
      tags = {
        Purpose = "Application logs"
      }
    }
    data = {
      versioning = true
      tags = {
        Purpose = "Application data"
      }
    }
    backup = {
      versioning = true
      tags = {
        Purpose = "Backup storage"
      }
    }
  }
}

# Object type - structured configuration
variable "notification_config" {
  description = "SNS notification configuration"
  type = object({
    enabled = bool
    email   = string
  })
  default = {
    enabled = false
    email   = "admin@example.com"
  }
}

# ------------------------------------------------------------
# SENSITIVE VARIABLES
# ------------------------------------------------------------

variable "secret_suffix" {
  description = "Secret suffix for bucket names (won't show in logs)"
  type        = string
  default     = "abc123"
  sensitive   = true
}
