variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "enable_caching" {
  description = "Disable caching during testing for convenience."
  type        = bool
  default     = true
}

#####################
## ACM & Route53 (Optional)
#####################
variable "acm_certificate_arn" {
  description = "ARN of ACM certificate. The certificate must be in the US East (N. Virginia) Region (us-east-1)."
  type        = string
  default     = ""

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^(arn:aws:acm:us-east-1:\\d{12}:certificate/)?", var.acm_certificate_arn))
    error_message = "ARN of ACM must match the \"^arn:aws:acm:us-east-1:\\d{12}:certificate/\" pattern or an empty string"
  }
}

variable "hosted_zone_name" {
  description = "Hosted zone name. Obtain this from your Route53 service."
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Hosted zone ID. Obtain this from your Route53 service."
  type    = string
  default     = ""
}