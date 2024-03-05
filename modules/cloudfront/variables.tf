variable "asg_origin_id" {
  type        = string
  description = "Origin ID of the load balancer"
}

variable "s3_origin_id" {
  type        = string
  description = "Origin ID of the s3 bucket"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of ACM certificate, to set custom SSL certificate"
}

variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone name from Route53"
}

variable "hosted_zone_id" {
  type        = string
  description = "Hosted zone ID from Route53"
}

variable "path_pattern" {
  type    = list(string)
  default = ["/*.jpg", "/maintenance.html"]
}

variable "method" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

################
## Toogle caching
################
variable "enable_caching" {
  type        = bool
  description = "Determine which of the below two policies to be used. Usually disabled during testing for convenience"
}

variable "Managed-CachingOptimized" {
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  description = <<-EOT
    CloudFront managed cache policy: Policy with caching enabled.
    Supports Gzip and Brotli compression.
    EOT
}

variable "Managed-CachingDisabled" {
  type        = string
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  description = "CloudFront managed cache policy: Policy with caching disabled"
}
