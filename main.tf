locals {
  default_tags = {
    description = "Kennys Medium Article"
    terraform   = true
  }
}

resource "random_string" "random_string" {
  length  = 16
  special = false
  upper   = false
}

module "vpc" {
  count              = var.enable_load_balancer_origin ? 1 : 0
  source             = "./modules/vpc"
  list_of_azs        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  default_tags       = local.default_tags
  ALB_sg_id          = module.asg[0].ALB_sg_id
  create_nat_gateway = true

  vpc_cidr_block                    = "10.1.0.0/16"
  list_of_public_subnet_cidr_range  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  list_of_private_subnet_cidr_range = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
}

module "cloudfront" {
  source                      = "./modules/cloudfront"
  enable_load_balancer_origin = var.enable_load_balancer_origin
  asg_origin_id               = var.enable_load_balancer_origin ? module.asg[0].origin_id : ""
  s3_origin_id                = module.s3.bucket_regional_domain_name
  enable_caching              = var.enable_caching
  acm_certificate_arn         = var.acm_certificate_arn
  hosted_zone_name            = var.hosted_zone_name
  hosted_zone_id              = var.hosted_zone_id
  enable_cloudfront_logging   = var.enable_cloudfront_logging
  logging_bucket_domain_name  = module.s3.logging_bucket_domain_name
  create_lambda_at_edge       = var.create_lambda_at_edge
  lambda_edge_arn             = var.create_lambda_at_edge ? module.lambda_at_edge.lambda_at_edge_qualified_arn : ""
  default_tags                = local.default_tags
}

module "asg" {
  count                   = var.enable_load_balancer_origin ? 1 : 0
  source                  = "./modules/asg"
  list_of_subnets         = module.vpc[0].list_of_public_subnet_ids
  default_tags            = local.default_tags
  list_of_security_groups = [module.vpc[0].sg_id]
  vpc_id                  = module.vpc[0].vpc_id
  desired_capacity        = 1
}

module "s3" {
  source                    = "./modules/s3_bucket"
  random_string             = random_string.random_string.id
  distribution_arn          = module.cloudfront.distribution_arn
  enable_cloudfront_logging = var.enable_cloudfront_logging
  default_tags              = local.default_tags
}

module "lambda_at_edge" {
  source = "./modules/lambda"
  # count  = var.create_lambda_at_edge ? 1 : 0
  create_lambda_at_edge = var.create_lambda_at_edge
  default_tags          = local.default_tags
  # providers = {
  #   aws = aws.useast1
  # }
}