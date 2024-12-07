variable "random_string" {
  type = string
}

variable "distribution_arn" {
  type = string
}

variable "enable_cloudfront_logging" {
  type = string
}

variable "default_tags" {
  type = map(any)
}