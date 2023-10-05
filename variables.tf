variable "name" {
  default = null
}

variable "log_bucket_name" {}

variable "log_bucket_force_destroy" {
  default = true
}

variable "load_balancer_type" {
  default = "application"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "listeners" {
  default = {}
}

variable "builtin_listeners" {
  type    = list(string)
  default = []
}

variable "region" {
  default = "us-east-1"
}