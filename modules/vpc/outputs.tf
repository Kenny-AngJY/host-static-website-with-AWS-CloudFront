output "vpc_id" {
  value = aws_vpc.main.id
}

output "sg_id" {
  value = aws_security_group.allow_tls.id
}

output "list_of_public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "list_of_private_subnet_ids" {
  value = aws_subnet.private[*].id
}