variable "create_lambda_at_edge" {
  description = "Toggle the creation of a Lambda function that is triggered during the origin request."
  type        = bool
  default     = false
}

variable "default_tags" {
  type = map(any)
}