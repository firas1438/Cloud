# Full-Stack AWS Cloud Infrastructure (Terraform)

This project demonstrates a highly available, 3-tier web application deployed on AWS using **Terraform (Infrastructure as Code)**.

## AWS VPC Architecture
![VPC Architecture](https://i.imgur.com/8bc933d.png)

## Infrastructure Specifications
This implementation strictly follows all project guidelines and academic requirements:

- **Networking**:
  - Custom **VPC** (CIDR `10.0.0.0/16`) with an Internet Gateway and NAT Gateway.
  - Multi-AZ deployment across **AZ-A** and **AZ-B**.
  - 4 Subnets total: 1 Public and 1 Private subnet per Availability Zone.
- **Compute & Scaling**:
  - **Auto Scaling Group (ASG)**: Configured with **Min: 2, Desired: 2, Max: 4** instances in private subnets.
  - **Scaling Policy**: Triggers automatic instance launch when **CPU usage > 70%**.
  - **Launch Template**: Fully automates server setup via **User Data** scripts.
- **Load Balancing**:
  - **Application Load Balancer (ALB)** in public subnets distributing traffic to the backend fleet.
  - Target Group with health checks on the `/health` endpoint.
- **Database**:
  - Managed **Amazon RDS (MySQL)** instance isolated in private subnets.
- **Security Groups**:
  - **ALB/Frontend**: Port 80 open to the world (`0.0.0.0/0`).
  - **Backend**: Port 3000 restricted *only* to the ALB Security Group.
  - **Database**: Port 3306 restricted *only* to the Backend Security Group.

## Tech Stack
- **Cloud Provider**: AWS (EC2, VPC, RDS, ALB, ASG)
- **IaC**: Terraform
- **Frontend**: Angular 19 (Served by Nginx)
- **Backend**: Node.js / Express.js
- **Database**: MySQL (Amazon RDS)

## Deployment Instructions
1. **Configure**: Create `terraform/terraform.tfvars` with your `db_password` and `github_repo`.
2. **Build**: 
   ```powershell
   cd terraform
   terraform init
   terraform apply
   ```

## Key Features & Demonstration
- **Self-Healing**: If a backend instance is terminated, the ASG automatically detects the failure and launches a new one.
- **Automated Provisioning**: Servers automatically install Node.js/Nginx, clone the repo, inject the ALB DNS, and build the app at launch.
- **Zero-Trust Networking**: Instances in private subnets have no public IPs and are only reachable through the Load Balancer.

## Cleanup
To avoid AWS costs, run:
```powershell
terraform destroy
```