output "lambda_at_edge_qualified_arn" {
  value = var.create_lambda_at_edge ? aws_lambda_function.origin_request[0].qualified_arn : ""
}