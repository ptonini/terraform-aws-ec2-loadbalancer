variable "name" {
  default = null
}

variable "internal" {
  default = false
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

variable "security_group" {
  type = object({
    enabled = optional(bool, true)
    vpc = optional(object({
      id = string
    }))
    ingress_rules = optional(map(object({
      from_port        = number
      to_port          = optional(number)
      protocol         = optional(string)
      cidr_blocks      = optional(set(string))
      ipv6_cidr_blocks = optional(set(string))
      prefix_list_ids  = optional(set(string))
      security_groups  = optional(set(string))
    })), {})
  })
  default = { enabled = false }
}