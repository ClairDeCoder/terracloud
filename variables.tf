variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "www.mywebsite.com"
}

variable "domain_name" {
  description = "Domain name for Route 53"
  default     = "mywebsite.com"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  default     = "production"
}
