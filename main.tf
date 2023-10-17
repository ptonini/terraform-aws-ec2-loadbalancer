locals {
  elb_account_id = {
    us-east-1 = "127311923021"
  }
}

data "aws_caller_identity" "current" {}

module "log_bucket" {
  source        = "ptonini/s3-bucket/aws"
  version       = "~> 2.0.0"
  name          = var.log_bucket.name
  create_policy = false
  force_destroy = var.log_bucket.force_destroy
  bucket_policy_statements = [
    {
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.elb_account_id[var.log_bucket.region]}:root" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${var.log_bucket.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::${var.log_bucket.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = "arn:aws:s3:::${var.log_bucket.name}"
    }
  ]
}

module "security_group" {
  source        = "ptonini/security-group/aws"
  version       = "~> 3.1.0"
  count         = var.security_group == null ? 0 : 1
  name          = "lb-${var.name}"
  vpc           = var.security_group.vpc
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  subnets            = var.subnet_ids
  security_groups    = concat(var.security_group == null ? [] : [module.security_group[0].this.id], var.additional_security_groups)
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
  source        = "ptonini/ec2-loadbalancer-listener/aws"
  version       = "~> 2.0.0"
  for_each      = var.listeners
  load_balancer = aws_lb.this
  port          = each.value.port
  protocol      = each.value.protocol
  certificate   = each.value.certificate
  actions       = each.value.actions
  rules         = each.value.rules
}

resource "aws_api_gateway_vpc_link" "this" {
  count       = var.create_api_gateway_vpc_link ? 1 : 0
  name        = var.name
  target_arns = [aws_lb.this.arn]
}