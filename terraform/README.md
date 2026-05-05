This directory contains the Terraform configuration to deploy the Full-Stack application on AWS.

#### Setup
1. Create `terraform.tfvars` with:
   ```hcl
   db_password = "your_db_password"
   github_repo = "https://github.com/your_username/your_repo.git"
   ```
2. Run `terraform init`
3. Run `terraform apply`

#### Outputs
- `frontend_public_ip`: Use this to access the Angular app in your browser.
- `alb_dns_name`: The URL of your backend load balancer.
- `rds_endpoint`: The database host.

#### Security
- RDS is isolated in private subnets.
- Backend is isolated in private subnets.
- Only the Frontend and ALB are public.
