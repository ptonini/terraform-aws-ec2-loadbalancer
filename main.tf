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
}

module "bucket" {
  source = "ptonini/s3-bucket/aws"
  version = "~> 1.0.0"
  name = var.log_bucket_name
  create_policy = false
  create_role = false
  force_destroy = var.log_bucket_force_destroy
  bucket_policy_statements = [
    {
      Effect = "Allow"
      Principal = {AWS = "arn:aws:iam::${local.elb_account_id[var.region]}:root"}
      Action = "s3:PutObject"
      Resource = "arn:aws:s3:::${var.log_bucket_name}/AWSLogs/${var.account_id}/*"
    },
    {
      Effect = "Allow"
      Principal = {Service = "delivery.logs.amazonaws.com"}
      Action = "s3:PutObject"
      Resource = "arn:aws:s3:::${var.log_bucket_name}/AWSLogs/${var.account_id}/*"
    },
    {
      Effect = "Allow"
      Principal = {Service = "delivery.logs.amazonaws.com"}
      Action = "s3:GetBucketAcl"
      Resource = "arn:aws:s3:::${var.log_bucket_name}"
    }
  ]
}

resource "aws_alb" "this" {
  subnets = var.subnet_ids
  security_groups = var.security_group_ids
  access_logs {
    bucket = module.bucket.this.id
    enabled = true
  }
}

module "listener" {
  source = "ptonini/ec2-loadbalancer-listener/aws"
  version = "~> 1.0.0"
  for_each = merge(var.listeners, local.selected_builtin_listeners)
  load_balancer = aws_alb.this
  port = try(each.value["port"], "443")
  protocol = try(each.value["protocol"], "HTTPS")
  certificate = try(each.value["certificate"], null)
  actions = try(each.value["actions"], {})
  builtin_actions = try(each.value["builtin_actions"], [])
  rules = try(each.value["rules"], {})
}