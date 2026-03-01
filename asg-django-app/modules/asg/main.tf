resource "aws_launch_template" "launch_template" {
  name_prefix     = "app-launch-template-"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  vpc_security_group_ids = [var.asg_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # your shell commands here
     yum update -y

     yum install docker -y

     systemctl start docker
     systemctl enable docker

     usermod -aG docker ec2-user
     docker run -d \
      --name django-app \
      --restart always \
      -p 80:80 \
     nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { 
        Name = "app-launch-template"
    }
  }
}

resource "aws_autoscaling_group" "ec2_asg" {
  name     = "app-asg"
  min_size = var.min
  max_size = var.max
  desired_capacity = var.desired
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [var.target_arn]
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  health_check_grace_period = 300
}