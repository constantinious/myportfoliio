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

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = false
    }

    content_security_policy {
      content_security_policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.tailwindcss.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com; connect-src 'self';"
      override                = false
    }
  }
}
