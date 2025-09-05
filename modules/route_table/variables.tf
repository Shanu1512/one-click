variable "vpc_id" {
  type        = string
  description = "VPC ID for route tables"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
  default     = []
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID"
  default     = ""
}

variable "nat_id" {
  type        = string
  description = "NAT Gateway ID"
  default     = ""
}
