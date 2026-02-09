# Route53 A record pointing to CloudFront distribution
resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website[0].domain_name
    zone_id                = aws_cloudfront_distribution.website[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# Data source to get the hosted zone ID
data "aws_route53_zone" "main" {
  name = var.hosted_zone_name
}
