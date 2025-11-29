# Exercise 01: Hello S3

Your first Terraform exercise! Create an S3 bucket using LocalStack.

## Learning Objectives

- Understand Terraform file structure
- Learn the basic workflow: init, plan, apply, destroy
- Create your first AWS resource (S3 bucket)
- Configure Terraform to work with LocalStack

## Key Concepts

### Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | Main configuration - providers and resources |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output value definitions |
| `terraform.tfstate` | State file (auto-generated, tracks resources) |

### The Provider Block

The provider tells Terraform which cloud to talk to and how to authenticate:

```hcl
provider "aws" {
  region = "us-east-1"
  # ... authentication config
}
```

For LocalStack, we override endpoints to point to `localhost:4566`.

### The Resource Block

Resources are the infrastructure you want to create:

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
}
```

- `aws_s3_bucket` = resource type (provider_service)
- `my_bucket` = local name (reference this in your code)
- `bucket` = argument (configuration for this resource)

## Instructions

### Step 1: Explore the code

Read through `main.tf` to understand what each block does.

### Step 2: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin.

### Step 3: Preview changes

```bash
terraform plan
```

Terraform shows what it WILL do without making changes.

### Step 4: Apply changes

```bash
terraform apply
```

Type `yes` to confirm. Terraform creates the S3 bucket.

### Step 5: Verify the bucket exists

```bash
# Using AWS CLI with LocalStack endpoint
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Step 6: Check outputs

```bash
terraform output
```

### Step 7: View state

```bash
terraform show
```

### Step 8: Clean up

```bash
terraform destroy
```

## Challenges

Once you complete the basic exercise, try these:

1. **Change the bucket name** - Edit `variables.tf`, run `terraform plan` to see the change
2. **Add tags** - Add a `tags` block to the bucket resource
3. **Create multiple buckets** - Add another `aws_s3_bucket` resource

## Code Walkthrough

### 1. Terraform Settings Block (main.tf lines 10-19)

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**What it does:** Declares dependencies before Terraform runs anything.

| Setting | Meaning |
|---------|---------|
| `required_version = ">= 1.0.0"` | Your Terraform CLI must be version 1.0.0 or higher |
| `source = "hashicorp/aws"` | Download the AWS provider from HashiCorp's registry |
| `version = "~> 5.0"` | Use version 5.x (the `~>` means "any 5.x but not 6.0") |

**Why it matters:** Ensures everyone on your team uses compatible versions.

---

### 2. Provider Block (main.tf lines 25-44)

```hcl
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
```

**What it does:** Configures HOW Terraform talks to AWS (or LocalStack).

| Setting | Purpose |
|---------|---------|
| `region` | Which AWS region to create resources in |
| `access_key` / `secret_key` | Authentication (LocalStack accepts "test") |
| `skip_*` settings | Disable AWS validation checks (LocalStack doesn't support them) |
| `endpoints { s3 = ... }` | **KEY**: Redirect S3 API calls to LocalStack instead of real AWS |
| `s3_use_path_style` | Use `localhost:4566/bucket` instead of `bucket.localhost:4566` |

**For real AWS**, this would be simpler:
```hcl
provider "aws" {
  region = "us-east-1"
  # Credentials come from ~/.aws/credentials or environment variables
}
```

---

### 3. Resource Block (main.tf lines 50-58)

```hcl
resource "aws_s3_bucket" "hello_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My First Terraform Bucket"
    Environment = "learning"
    Exercise    = "01-hello-s3"
  }
}
```

**This is the core of Terraform** - it declares what infrastructure to create.

**Anatomy:**
```
resource "TYPE" "LOCAL_NAME" {
  ARGUMENT = VALUE
}
```

| Part | Value | Meaning |
|------|-------|---------|
| Type | `aws_s3_bucket` | Create an S3 bucket (provider_resource format) |
| Local name | `hello_bucket` | How YOU reference it in your code |
| `bucket` | The actual bucket name in AWS |
| `tags` | Metadata key-value pairs (useful for cost tracking, filtering) |

**Referencing this resource elsewhere:**
```hcl
aws_s3_bucket.hello_bucket.id    # The bucket name
aws_s3_bucket.hello_bucket.arn   # The Amazon Resource Name
```

---

### 4. Output Blocks (main.tf lines 64-77)

```hcl
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.hello_bucket.id
}
```

**What it does:** Displays values after `terraform apply` and makes them available to other Terraform configurations.

**The reference syntax:** `aws_s3_bucket.hello_bucket.id`
- `aws_s3_bucket` = resource type
- `hello_bucket` = local name we gave it
- `id` = attribute exported by this resource type

---

### 5. Variables (variables.tf)

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "my-first-terraform-bucket"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters..."
  }
}
```

**What it does:** Defines inputs that can be customized without editing the main code.

| Field | Purpose |
|-------|---------|
| `description` | Documents what this variable is for |
| `type` | Data type (`string`, `number`, `bool`, `list`, `map`) |
| `default` | Value if none provided |
| `validation` | Custom rules - here it enforces AWS bucket naming rules |

**Ways to override defaults:**
```bash
# Command line
terraform apply -var="bucket_name=my-custom-bucket"

# Environment variable
export TF_VAR_bucket_name="my-custom-bucket"

# File (terraform.tfvars)
bucket_name = "my-custom-bucket"
```

---

### The Flow

```
┌─────────────────┐
│  variables.tf   │  ← Defines inputs
└────────┬────────┘
         │ var.bucket_name
         ▼
┌─────────────────┐
│    main.tf      │
│  ┌───────────┐  │
│  │ terraform │  │  ← Version constraints
│  └───────────┘  │
│  ┌───────────┐  │
│  │ provider  │  │  ← How to connect
│  └───────────┘  │
│  ┌───────────┐  │
│  │ resource  │  │  ← What to create
│  └───────────┘  │
│  ┌───────────┐  │
│  │ output    │  │  ← What to display
│  └───────────┘  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   LocalStack    │  ← S3 bucket created here
└─────────────────┘
```

---

## Common Errors

| Error | Solution |
|-------|----------|
| "Provider not found" | Run `terraform init` |
| "Bucket already exists" | Change bucket name or run `terraform destroy` first |
| "Connection refused" | Make sure LocalStack is running |

## Next Steps

Once comfortable, move to [Exercise 02: Variables & Outputs](../02-variables-outputs/)
