variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "Base name for EC2 resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access port 8080"
  type        = list(string)
}

variable "app_s3_bucket" {
  description = "S3 bucket where server.rb is stored"
  type        = string
}