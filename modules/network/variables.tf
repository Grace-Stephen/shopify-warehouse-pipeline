variable "project_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "ogoma"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for first private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR for second private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "az1" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Secondary availability zone"
  type        = string
  default     = "us-east-1b"
}
