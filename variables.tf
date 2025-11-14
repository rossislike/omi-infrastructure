variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "omi-frontend"
    Environment = "prod"
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
  default     = "prod"
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
  default     = "prod"
}

variable "state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "omi-state"
}

variable "env_domain" {
  description = "The URL of the website"
  type        = map(string)
  default = {
    "dev"  = "dev.overcomerministriesinternational.org"
    "prod" = "overcomerministriesinternational.org"
  }
}

variable "domain_name" {
  description = "The domain name of the website"
  type        = string
  default     = "overcomerministriesinternational.org"
}

variable "zone_id" {
  description = "The hosted zone id"
  type        = string
  default     = "Z08834033S2ZP1KBMJYDE"
}

variable "certificate_arn" {
  description = "The certificate arn"
  type        = string
  default     = "arn:aws:acm:us-east-1:585768164578:certificate/c3f7fa31-b459-4d05-ba5b-c7882509ce31"
}

variable "cloudfront_domain_name" {
  description = "CloudFront domain name"
  type        = string
  default     = "d1nbkiyoyvj3fx.cloudfront.net"
}