variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for the website (optional, required for Route53 record)"
  type        = string
  default     = ""
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
  default     = "condevelop.net"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for the website"
  type        = string
  default     = "konstantinos-gkekas-portfolio"
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}
