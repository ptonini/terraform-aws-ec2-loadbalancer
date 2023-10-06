variable "name" {
  default = null
}

variable "internal" {
  default = false
}

variable "load_balancer_type" {
  default = "application"
}

variable "subnet_ids" {
  type = list(string)
}

variable "log_bucket" {
  type = object({
    name          = string
    region        = string
    force_destroy = optional(bool, true)
  })
}

variable "security_group" {
  type = object({
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
    })))
  })
}

variable "listeners" {
  type = map(object({
    port            = optional(number)
    protocol        = optional(string)
    certificate     = optional(string)
    actions         = optional(any, {})
    builtin_actions = optional(any, [])
    rules           = optional(any, {})
  }))
  default = {}
}

variable "create_api_gateway_vpc_link" {
  default = false
}