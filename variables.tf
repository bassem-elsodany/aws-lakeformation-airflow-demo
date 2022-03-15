variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}


variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "development"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
