variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  default     = "projet-cloud"
}

variable "db_username" {
  description = "Database administrator username"
  default     = "admin"
}

variable "db_password" {
  description = "Database administrator password"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  default     = "cloud_db"
}

variable "github_repo" {
  description = "GitHub repository URL for the code"
  default     = "https://github.com/firas1438/Cloud.git"
}
