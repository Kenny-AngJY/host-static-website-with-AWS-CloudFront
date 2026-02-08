output "vpc_id" {
  value = var.enable_load_balancer_origin ? module.vpc[0].vpc_id : "NA"
}

output "sg_id" {
  value = var.enable_load_balancer_origin ? module.vpc[0].sg_id : "NA"
}

output "random_test" {
  value = random_string.random_string.id
}

output "CloudFront_Distribution_Domain_Name" {
  value = module.cloudfront.distribution_domain_name
}

output "aws_canonical_user_id" {
  value = module.s3.aws_canonical_user_id
}

output "create_lambda_at_edge" {
  value = var.create_lambda_at_edge
}

output "bucket_regional_domain_name" {
  value = module.s3.bucket_regional_domain_name
}

output "lambda_at_edge_qualified_arn" {
  value = module.lambda_at_edge.lambda_at_edge_qualified_arn
}