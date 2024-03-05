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
  source                    = "./modules/vpc"
  vpc_cidr_block            = "10.1.0.0/16"
  list_of_subnet_cidr_range = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  list_of_azs               = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  default_tags              = local.default_tags
  ALB_sg_id                 = module.asg.ALB_sg_id
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  asg_origin_id       = module.asg.origin_id
  s3_origin_id        = format("%s.s3.ap-southeast-1.amazonaws.com", module.s3.full_bucket_name)
  enable_caching      = var.enable_caching
  acm_certificate_arn = var.acm_certificate_arn
  hosted_zone_name    = var.hosted_zone_name
  hosted_zone_id      = var.hosted_zone_id
}

module "asg" {
  source                  = "./modules/asg"
  list_of_subnets         = module.vpc.list_of_subnet_ids
  default_tags            = local.default_tags
  list_of_security_groups = [module.vpc.sg_id]
  vpc_id                  = module.vpc.vpc_id
  desired_capacity        = 1
}

module "s3" {
  source           = "./modules/s3_bucket"
  bucket_name      = format("terraform-cloudfront-%s", random_string.random_string.id)
  distribution_arn = module.cloudfront.distribution_arn
}