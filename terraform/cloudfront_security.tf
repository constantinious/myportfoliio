# CloudFront Response Headers Policy for Security
# Adds important security headers to all responses

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "portfolio-security-headers"

  security_headers_config {
    # Prevent click-jacking attacks
    frame_options {
      frame_option = "DENY"
      override     = false
    }

    # Prevent MIME sniffing
    content_type_options {
      override = false
    }

    # Enable browser XSS protection
    xss_protection {
      mode_block = true
      protection = true
      override   = false
    }

    # Referrer policy
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = false
    }
  }

  custom_headers_config {
    items {
      header   = "Strict-Transport-Security"
      value    = "max-age=31536000; includeSubDomains; preload"
      override = false
    }
    items {
      header   = "Content-Security-Policy"
      value    = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self';"
      override = false
    }
  }
}
