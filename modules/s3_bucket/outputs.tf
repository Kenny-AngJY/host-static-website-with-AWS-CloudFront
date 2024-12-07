output "full_bucket_name" {
  value = aws_s3_bucket.main.id
}

output "logging_bucket_domain_name" {
  value = var.enable_cloudfront_logging ? aws_s3_bucket.standard_logging[0].bucket_domain_name : ""
}

output "aws_canonical_user_id" {
  value = data.aws_canonical_user_id.current.id
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.main.bucket_regional_domain_name
}