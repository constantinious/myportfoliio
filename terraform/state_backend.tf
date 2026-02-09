# S3 Bucket for Terraform State
# This bucket stores the Terraform state file in a safe, versioned location
# Uses native S3 locking via state.lock object

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}-terraform-state"

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Block public access to state bucket (CRITICAL)
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for state file recovery
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for state file (CRITICAL)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable access logging for state bucket (AUDIT)
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.terraform_state_logs.id
  target_prefix = "state-bucket-logs/"
}

# Logging bucket for state bucket access logs
resource "aws_s3_bucket" "terraform_state_logs" {
  bucket = "${var.bucket_name}-terraform-state-logs"

  tags = {
    Name = "Terraform State Logs Bucket"
  }
}

# Block public access to logs bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_logs" {
  bucket = aws_s3_bucket.terraform_state_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_logs" {
  bucket = aws_s3_bucket.terraform_state_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable lifecycle rule to delete old logs
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_logs" {
  bucket = aws_s3_bucket.terraform_state_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"
    filter {}

    expiration {
      days = 90
    }
  }
}
