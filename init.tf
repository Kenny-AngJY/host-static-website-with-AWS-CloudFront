terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }
  }

  required_version = "~> 1.14"
}

provider "aws" {
  region = var.region
  # These default tags below will be applied to the resource
  # if no tags are explictly defined in the resource.
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }
}
