locals {
  elb_account_id = {
    us-east-1 = "127311923021"
  }
  builtin_listeners = {
    http_to_https = {
      port = 80
      protocol = "HTTP"
      builtin_actions = ["redirect_to_https"]
    }
  }
  selected_builtin_listeners = {for l in var.builtin_listeners : l => local.builtin_listeners[l]}
  listeners = merge(var.listeners, local.selected_builtin_listeners)
}

