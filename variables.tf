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
      from_port                    = number
      to_port                      = optional(number)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
    })))
    egress_rules = optional(map(object({
      from_port                    = number
      to_port                      = optional(number)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
    })), { self = { from_port = 0, ip_protocol = -1, referenced_security_group_id = "self" } })
  })
  default = null
}

variable "additional_security_groups" {
  type    = list(string)
  default = []
}

variable "listeners" {
  type = map(object({
    port        = optional(number)
    protocol    = optional(string)
    certificate = optional(any)
    actions     = optional(any, {})
    rules       = optional(any, {})
  }))
  default = {}
}

variable "create_api_gateway_vpc_link" {
  default = false
}