# AWS Cloud Infrastructure with Terraform

This project implements a highly available, 3-tier web architecture on AWS using Terraform.

## Folder Structure
```text
projet_cloud/
├── backend/            # Express.js API
├── client/             # Angular Frontend
├── terraform/          # Infrastructure as Code
│   ├── alb.tf          # Load Balancer & Target Groups
│   ├── backend_asg.tf  # Auto Scaling Group for Backend
│   ├── frontend.tf     # EC2 Instance for Frontend
│   ├── outputs.tf      # Important URLs after deployment
│   ├── provider.tf     # AWS Config
│   ├── rds.tf          # MySQL Database
│   ├── sg.tf           # Security Groups (Firewalls)
│   ├── variables.tf    # Configurable inputs
│   ├── vpc.tf          # Network (VPC, Subnets, NAT)
│   └── terraform.tfvars # (YOU CREATE THIS) Your secrets
└── README.md
```

---

## How to Run (Step-by-Step)

### 1. Prerequisites
*   **AWS CLI** installed and configured (`aws configure`).
*   **Terraform** installed.
*   Your code pushed to a **Public GitHub Repository** (so EC2 can clone it).

### 2. Configuration
Create a file named `terraform.tfvars` inside the `terraform/` folder:
```hcl
db_password = "your_secret_db_password"
github_repo = "https://github.com/username/repo.git"
```

### 3. Execution Commands
Open your terminal in the `terraform/` folder and run:

1.  **Initialize**: Downloads AWS plugins.
    ```powershell
    terraform init
    ```
2.  **Plan**: Preview what will be created.
    ```powershell
    terraform plan
    ```
3.  **Apply**: Build everything (type `yes` when asked).
    ```powershell
    terraform apply
    ```

---

## What to Change (Minimal)
1.  **`terraform.tfvars`**: Put your own GitHub repo link and a strong password.
2.  **`frontend.tf`**: I've added a `sed` command to automatically replace `localhost:3000` with your ALB URL. Ensure your Angular service uses `http://localhost:3000` as the base URL.

---

## How to Demo to the Professor

### 1. Show the Website
*   Run `terraform output`.
*   Copy the `frontend_public_ip`.
*   Open it in a browser: `http://<IP>`.
*   Show that you can add/view users (it talks to the Backend via ALB, which talks to RDS).

### 2. Prove Security (The "Firewall" Check)
*   Go to **AWS Console > Security Groups**.
*   **RDS SG**: Show that it *only* allows traffic from the Backend SG (Port 3306).
*   **Backend SG**: Show that it *only* allows traffic from the ALB SG (Port 3000).
*   **Public IP**: Show that you *cannot* connect to the RDS or Backend directly from your laptop.

### 3. Prove Resilience (The "Chaos" Test)
*   Go to **EC2 Instances**.
*   Terminate one of the Backend instances.
*   Wait 2 minutes.
*   Show the Professor that the **Auto Scaling Group** automatically started a new instance to replace the dead one.

---

## Simple Explanation
*   **VPC**: Your own private piece of the AWS cloud.
*   **Public Subnets**: Where things that need internet live (ALB, Frontend).
*   **Private Subnets**: Where the "brains" (Backend) and "memory" (Database) hide for safety.
*   **NAT Gateway**: A one-way door allowing private servers to download updates from the internet without being exposed.
*   **ALB**: A traffic cop that sends users to the healthiest Backend server.
*   **ASG**: A robot that adds more servers if the CPU gets too hot (>70%) and replaces broken ones.
*   **RDS**: A managed MySQL database that handles backups and updates for you.
