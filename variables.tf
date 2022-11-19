variable "log_bucket_name" {}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "listeners" {
  default = {}
}

variable "builtin_listeners" {
  type = list(string)
  default = []
}

variable "region" {
  default = "us-east-1"
}

variable "account_id" {}