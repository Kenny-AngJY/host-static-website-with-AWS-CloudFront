data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "this" {
  name                   = "terraform_cloudfront_launch_template"
  image_id               = data.aws_ami.amazon-linux-2.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = var.list_of_security_groups

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
  metadata_options {
    # Whether the metadata service is available
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = filebase64("./scripts/user-data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.default_tags,
      {
        Name = "terraform-cloudfront-ec2-origin"
      }
    )
  }
}

resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier = var.list_of_subnets
  desired_capacity    = var.desired_capacity
  max_size            = var.desired_capacity
  min_size            = var.desired_capacity
  target_group_arns   = ["${aws_lb_target_group.lb_target_group.arn}"]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "terraform_cloudfront_instance_profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name                = "terraform_cloudfront_instance_role"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  tags                = var.default_tags
}

resource "aws_lb" "alb" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = var.list_of_subnets
  enable_deletion_protection = false
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_alb"
    },
  )
}

resource "aws_lb_target_group" "lb_target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = merge(
    var.default_tags,
    {
      Name = "terraform_target_group"
    }
  )
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


resource "aws_security_group" "lb_sg" {
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Everything"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Everything"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      Name = "terraform_cloudfront_alb_securitygroup"
    },
  )
}