# all variables will be taken from module call

# define locals that can be used in module only 
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

# instance security group
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

# read remote state of database outputs
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}

# define user data
data "template_file" "user_data" {
  # when used with modules you need to give the path module variable; otherwise it will not find the file
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    # the remote state above defined with name db. now we are reading it
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }
}

#1 for autoscaling we need a launch configuration
resource "aws_launch_configuration" "example" {
  image_id        = "ami-070062dd89dbb7eba"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.instance.id]
  # put spot price for getting spot instances
  spot_price    = "0.005"

  # this renders the template file
  user_data = data.template_file.user_data.rendered

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

#2 define VPC for as data
data "aws_vpc" "default" {
  default = true
}

#3 define subnets as data
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

#4 define security group for load balancer
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

#5 define load balancer
resource "aws_lb" "example" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

#6 define the listener for laod balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

#7 define load balancer target group
resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-alb"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#8 Create autoscaling group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

#9 create listener rule for load balancer
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}