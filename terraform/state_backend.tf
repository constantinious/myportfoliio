# S3 Bucket for Terraform State
# This bucket stores the Terraform state file in a safe, versioned location
# Uses native S3 locking via state.lock object

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}-terraform-state"

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Block public access to state bucket
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

# Enable server-side encryption for state file
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable MFA delete protection (optional but recommended)
# Uncomment if you want to require MFA to delete state files
# resource "aws_s3_bucket_object_lock_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   rule {
#     default_retention {
#       mode = "GOVERNANCE"
#       days = 30
#     }
#   }
# }
