### Creating a VPC also creates a default (main) route table and default (main) NACL
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
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

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_cloudfront_custom_routetable"
    },
  )
}

resource "aws_subnet" "public_subnet" {
  # If you do not explictly state which route table the subnet is associated with,
  # it will be associated with the default route table.
  count                   = length(var.list_of_azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.list_of_subnet_cidr_range[count.index]
  availability_zone       = var.list_of_azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.default_tags,
    {
      Name = format("terraform_cloudfront_public_subnet_%s", (count.index + 1))
    },
  )
}

resource "aws_route_table_association" "public_1" {
  count          = length(var.list_of_azs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "allow_tls" {
  name        = "terraform_cloudfront_ec2_securitygroup"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Only allow traffic from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = []
    security_groups = [var.ALB_sg_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.default_tags, { Name = "terraform_cloudfront_securitygroup" })
}