# Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              set -e # Stop on error
              exec > /var/log/user-data.log 2>&1 # Log everything to this file

              echo "--- 1. Adding Swap Space (Prevents t2.micro crashes) ---"
              fallocate -l 2G /swapfile
              chmod 600 /swapfile
              mkswap /swapfile
              swapon /swapfile
              echo '/swapfile none swap sw 0 0' >> /etc/fstab

              echo "--- 2. Installing Dependencies ---"
              apt update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt install -y nodejs git nginx

              echo "--- 3. Cloning and Injecting ALB DNS ---"
              cd /home/ubuntu
              git clone ${var.github_repo} app
              cd app/client
              sed -i 's|http://localhost:3000|http://${aws_lb.backend_alb.dns_name}|g' src/app/services/user.service.ts

              echo "--- 4. Building Angular App (Might take 5-10 mins) ---"
              npm install
              export NODE_OPTIONS="--max-old-space-size=1536"
              npm run build

              echo "--- 5. Deploying to Public Web Folder (Fixes Permission Denied) ---"
              sudo mkdir -p /var/www/html/angular-app
              # Copy files - checking both possible Angular output paths
              if [ -d "dist/client/browser" ]; then
                sudo cp -r dist/client/browser/* /var/www/html/angular-app/
              else
                sudo cp -r dist/client/* /var/www/html/angular-app/
              fi
              
              sudo chown -R www-data:www-data /var/www/html/angular-app
              sudo chmod -R 755 /var/www/html/angular-app

              echo "--- 6. Configuring Nginx ---"
              rm -f /etc/nginx/sites-enabled/default
              cat <<EON > /etc/nginx/sites-available/angular-app
              server {
                  listen 80;
                  server_name _;
                  root /var/www/html/angular-app;
                  index index.html;
                  location / {
                      try_files \$uri \$uri/ /index.html;
                  }
              }
              EON
              ln -sf /etc/nginx/sites-available/angular-app /etc/nginx/sites-enabled/
              systemctl restart nginx
              
              echo "Setup complete! Visit your IP now."
              EOF

  tags = {
    Name = "${var.project_name}-frontend"
  }
}
