output "distribution_arn" {
  value = aws_cloudfront_distribution.elb_s3_distribution.arn
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.elb_s3_distribution.domain_name
}