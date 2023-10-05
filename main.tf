locals {
  elb_account_id = {
    us-east-1 = "127311923021"
  }
  builtin_listeners = {
    http_to_https = {
      port            = 80
      protocol        = "HTTP"
      builtin_actions = ["redirect_to_https"]
    }
  }
  selected_builtin_listeners = { for l in var.builtin_listeners : l => local.builtin_listeners[l] }
}

data "aws_caller_identity" "current" {}

module "log_bucket" {
  source        = "ptonini/s3-bucket/aws"
  version       = "~> 2.0.0"
  name          = var.log_bucket_name
  create_policy = false
  force_destroy = var.log_bucket_force_destroy
  bucket_policy_statements = [
    {
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.elb_account_id[var.region]}:root" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${var.log_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${var.log_bucket_name}/AWSLogs/${var.account_id}/*"
    },
    {
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = "arn:aws:s3:::${var.log_bucket_name}"
    }
  ]
}

resource "aws_lb" "this" {
  name = var.name
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids
  load_balancer_type = var.load_balancer_type
  access_logs {
    bucket  = module.log_bucket.this.id
    enabled = true
  }
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

module "listener" {
  source          = "ptonini/ec2-loadbalancer-listener/aws"
  version         = "~> 2.0.0"
  for_each        = merge(var.listeners, local.selected_builtin_listeners)
  load_balancer   = aws_lb.this
  port            = try(each.value["port"], null)
  protocol        = try(each.value["protocol"], null)
  certificate     = try(each.value["certificate"], null)
  actions         = try(each.value["actions"], {})
  builtin_actions = try(each.value["builtin_actions"], [])
  rules           = try(each.value["rules"], {})
}