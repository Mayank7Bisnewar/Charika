variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_database_name" {
  description = "Database name"
  type        = string
  default     = "charika"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "jwt_secret_key" {
  description = "JWT secret key"
  type        = string
  default     = "change-me"
}

variable "google_maps_api_key" {
  description = "Google Maps API key"
  type        = string
  default     = "YOUR_GOOGLE_MAPS_API_KEY"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}
