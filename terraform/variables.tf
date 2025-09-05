variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


# VPC Peer variables
variable "peer_vpc_id" {
  description = "VPC ID of Jenkins VPC to peer with"
  type        = string
}

variable "jenkins_vpc_id" {
  description = "Jenkins VPC ID"
  type        = string
}

# variable "vpc_cidr" {
#   description = "CIDR of management VPC"
#   type        = string
# }

variable "jenkins_vpc_cidr" {
  description = "CIDR of Jenkins VPC"
  type        = string
}

# variable "jenkins_rt_ids" {
#   description = "Route table ID of Jenkins VPC"
#   type        = string
# }

variable "jenkins_sg_id" {
  description = "SG ID of Jenkins VPC for DB access"
  type        = string
}

variable "jenkins_rt_ids" {
  description = "List of Route Table IDs for Jenkins VPC"
  type        = list(string)
}
