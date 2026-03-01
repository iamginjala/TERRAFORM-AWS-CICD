resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_id

  tags = {
    Environment = "learning"
  }
}
resource "aws_lb_target_group" "test_target" {
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb_listener" "lstener" {
  load_balancer_arn = aws_lb.test.arn
  protocol = "HTTP"
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test_target.arn
  }
}
