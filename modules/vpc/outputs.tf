output "vpc_id" {
  value = aws_vpc.main.id
}

output "sg_id" {
  value = aws_security_group.allow_tls.id
}

output "list_of_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
