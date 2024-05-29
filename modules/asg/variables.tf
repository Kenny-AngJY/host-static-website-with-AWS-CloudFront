variable "list_of_subnets" {
  type = list(any)
}

variable "default_tags" {
  type = map(any)
}

variable "list_of_security_groups" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity for ASG"
}