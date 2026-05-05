# Frontend EC2 Instance

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt install -y nodejs git nginx

              cd /home/ubuntu
              git clone ${var.github_repo} app
              cd app/client

              # Replace backend URL with ALB DNS
              # In your UserService, the URL is 'http://localhost:3000/api/users'
              # We change it to 'http://${aws_lb.backend_alb.dns_name}/api/users'
              sed -i 's|http://localhost:3000|http://${aws_lb.backend_alb.dns_name}|g' src/app/services/user.service.ts

              npm install
              npm run build

              # Configure Nginx to serve the Angular app
              # Assumes build output is in dist/client/browser (Angular 17+)
              # Check your angular.json for the exact path
              rm /etc/nginx/sites-enabled/default
              cat <<EON > /etc/nginx/sites-available/angular-app
              server {
                  listen 80;
                  server_name _;
                  root /home/ubuntu/app/client/dist/client/browser;
                  index index.html;
                  location / {
                      try_files \$uri \$uri/ /index.html;
                  }
              }
              EON
              ln -s /etc/nginx/sites-available/angular-app /etc/nginx/sites-enabled/
              systemctl restart nginx
              EOF

  tags = {
    Name = "${var.project_name}-frontend"
  }
}
