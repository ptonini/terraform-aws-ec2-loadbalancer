module "bucket" {
  source = "github.com/ptonini/terraform-aws-s3-bucket?ref=v1"
  name = var.log_bucket_name
  create_policy = false
  create_role = false
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
  providers = {
    aws = aws
  }
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
  source = "github.com/ptonini/terraform-aws-ec2-loadbalancer-listener?ref=v1"
  for_each = local.listeners
  load_balancer = aws_alb.this
  port = try(each.value["port"], "443")
  protocol = try(each.value["protocol"], "HTTPS")
  certificate = try(each.value["certificate"], null)
  actions = try(each.value["actions"], {})
  builtin_actions = try(each.value["builtin_actions"], [])
  rules = try(each.value["rules"], {})
  providers = {
    aws = aws
  }
}

