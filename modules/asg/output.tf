output "origin_id" {
  value = aws_lb.alb.dns_name
}

output "ALB_sg_id" {
  value = aws_security_group.lb_sg.id
}