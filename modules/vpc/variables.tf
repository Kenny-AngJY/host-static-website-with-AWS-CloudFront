variable "default_tags" {
  type = map(any)
}

variable "vpc_cidr_block" {
  type = string
}

### list (or tuple): a sequence of values
variable "list_of_subnet_cidr_range" {
  type = list(string)
  ### Functions may not be called here.
  #   default = cidrsubnets("10.1.0.0/20", 4, 4, 4)
}

variable "list_of_azs" {
  type = list(string)
}

variable "ALB_sg_id" {
  type = string
}
