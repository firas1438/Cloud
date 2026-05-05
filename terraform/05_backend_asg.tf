# Backend Auto Scaling Group

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Launch Template
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt install -y nodejs git

              cd /home/ubuntu
              git clone ${var.github_repo} app
              cd app/backend
              
              # Set environment variables
              echo "DB_HOST=${aws_db_instance.mysql.address}" >> .env
              echo "DB_USER=${var.db_username}" >> .env
              echo "DB_PASSWORD=${var.db_password}" >> .env
              echo "DB_NAME=${var.db_name}" >> .env
              echo "USE_JSON_STORAGE=false" >> .env
              echo "PORT=3000" >> .env

              npm install
              npm start &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-backend-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "backend_asg" {
  name                = "${var.project_name}-backend-asg"
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  target_group_arns   = [aws_lb_target_group.backend_tg.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend-asg"
    propagate_at_launch = true
  }
}

# Scaling Policy
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
