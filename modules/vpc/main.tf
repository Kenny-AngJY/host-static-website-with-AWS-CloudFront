### Creating a VPC also creates a default (main) route table and default (main) NACL
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_cloudfront_vpc"
    },
  )
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_cloudfront_igw"
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_cloudfront_public_routetable"
    },
  )
}

resource "aws_subnet" "public" {
  # If you do not explictly state which route table the subnet is associated with,
  # it will be associated with the default route table.
  count                   = length(var.list_of_azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.list_of_public_subnet_cidr_range[count.index]
  availability_zone       = var.list_of_azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.default_tags,
    {
      Name = format("terraform_cloudfront_public_subnet_%s", (count.index + 1))
    },
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.list_of_azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  # If you do not explictly state which route table the subnet is associated with,
  # it will be associated with the default route table.
  count                   = length(var.list_of_azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.list_of_private_subnet_cidr_range[count.index]
  availability_zone       = var.list_of_azs[count.index]
  map_public_ip_on_launch = false
  tags = merge(
    var.default_tags,
    {
      Name = format("terraform_cloudfront_private_subnet_%s", (count.index + 1))
    },
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[0].id
  }
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_cloudfront_private_routetable"
    },
  )
}

resource "aws_eip" "nat_gw" {
  count      = var.create_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet-gw]
}

resource "aws_nat_gateway" "public" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_gw[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT-GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet-gw]
}

resource "aws_route_table_association" "private" {
  count          = length(var.list_of_azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "allow_tls" {
  name        = "terraform_cloudfront_ec2_securitygroup"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.default_tags, { Name = "terraform_cloudfront_securitygroup" })
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  description       = "Only allow traffic from ALB"
  security_group_id = aws_security_group.allow_tls.id

  referenced_security_group_id = var.ALB_sg_id
  from_port                    = "-1"
  ip_protocol                  = "-1"
  to_port                      = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.allow_tls.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "-1"
  ip_protocol = "-1"
  to_port     = "-1"
}