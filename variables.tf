variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  default     = "cicd-project"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
