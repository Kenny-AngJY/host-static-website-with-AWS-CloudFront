resource "aws_cloudfront_distribution" "elb_s3_distribution" {
  comment             = "Created from Terraform"
  default_root_object = "index.html"
  enabled             = true
  default_cache_behavior {
    allowed_methods = var.method
    cached_methods  = var.method
    # path_pattern = "/*"
    # Do not put s3_origin_id as the default origin. 
    # The successful creation of Cloudfront distribution on terraform requires
    # the distribution to be deployed. Which requires CF to be able to reach the origin.
    # However, the S3 bucket policy requires the CF arn, resulting in the S3 bucket policy
    # not being created. Bucket policy waiting for CF to be deployed, CF waiting for
    # S3 to grant it permission. Resulting in a circular dependency.
    target_origin_id       = var.asg_origin_id
    compress               = true
    cache_policy_id        = var.enable_caching ? var.Managed-CachingOptimized : var.Managed-CachingDisabled
    viewer_protocol_policy = "allow-all" # allow-all | https-only | redirect-to-https
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.path_pattern
    content {
      allowed_methods        = var.method
      cache_policy_id        = var.enable_caching ? var.Managed-CachingOptimized : var.Managed-CachingDisabled
      cached_methods         = var.method
      compress               = true
      default_ttl            = 0
      max_ttl                = 0
      min_ttl                = 0
      path_pattern           = ordered_cache_behavior.value
      smooth_streaming       = false
      target_origin_id       = var.s3_origin_id
      trusted_key_groups     = []
      trusted_signers        = []
      viewer_protocol_policy = "allow-all"
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = var.asg_origin_id
    origin_id           = var.asg_origin_id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only" # http-only | https-only | match-viewer
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = var.s3_origin_id
    origin_id                = var.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 503
    response_code         = 503
    response_page_path    = "/maintenance.html"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  aliases = var.acm_certificate_arn != "" ? ["www.${var.hosted_zone_name}"] : []

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.acm_certificate_arn != "" ? false : true
    minimum_protocol_version       = "TLSv1" # "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "terraform-cloudfront-OAC"
  description                       = "created-from-terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_route53_record" "www" {
  count   = var.acm_certificate_arn != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = format("www.%s", var.hosted_zone_name)
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.elb_s3_distribution.domain_name]
}
