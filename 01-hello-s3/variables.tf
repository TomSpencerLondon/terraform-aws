# ============================================================
# VARIABLES
# Input values that can be customized
# ============================================================

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

variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "my-first-terraform-bucket"

  # Validation to ensure bucket name follows AWS naming rules
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase, and can contain hyphens and dots."
  }
}
