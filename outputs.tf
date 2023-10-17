output "this" {
  value = aws_lb.this
}

output "api_gateway_vpc_link" {
  value = var.create_api_gateway_vpc_link ? aws_api_gateway_vpc_link.this : null
}