#############################
# DATA: Último AMI de Amazon Linux 2
#############################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#############################
# SECURITY GROUPS
#############################

# SG para el ALB
resource "aws_security_group" "alb_sg" {
  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# SG para las instancias EC2
resource "aws_security_group" "ec2_sg" {
  name   = "${var.environment}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ec2-sg"
  }
}

#############################
# APPLICATION LOAD BALANCER (ALB)
#############################

resource "aws_lb" "app_lb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

#############################
# LAUNCH TEMPLATE CON USER DATA
#############################

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y nginx1
    systemctl start nginx
    systemctl enable nginx
    echo "Hola Terraform" > /usr/share/nginx/html/index.html
EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-instance"
    }
  }
}

#############################
# AUTO SCALING GROUP
#############################

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.environment}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
}
