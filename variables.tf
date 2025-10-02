variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "omi-frontend"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "omi-frontend"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "rossislike"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "omi-frontend"
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "dev"
}

variable "state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "omi-state"
}
# variable "github_token" {
#   description = "GitHub personal access token"
#   type        = string
#   sensitive   = true
# }

