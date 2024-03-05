output "vpc_id" {
  value = module.vpc.vpc_id
}

output "sg_id" {
  value = module.vpc.sg_id
}

output "list_of_subnet_ids" {
  value = module.vpc.list_of_subnet_ids
}

output "random_test" {
  value = random_string.random_string.id
}

output "CloudFront_Distribution_Domain_Name" {
  value = module.cloudfront.distribution_domain_name
}