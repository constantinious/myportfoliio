output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "terraform_state_bucket" {
  description = "S3 bucket for Terraform state files"
  value       = aws_s3_bucket.terraform_state.id
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 A record"
  value       = var.domain_name != "" ? aws_route53_record.website.fqdn : null
}

output "deploy_command" {
  description = "Command to deploy files to S3"
  value       = "aws s3 sync ../website s3://${aws_s3_bucket.website.id}/"
}
