variable "vpc_id" {
  description = "VPC ID where the NACL will be created"
  type        = string
}

variable "name" {
  description = "Name tag for the NACL"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this NACL"
  type        = list(string)
}

variable "ingress_rules" {
  description = "List of ingress rules for NACL"
  type = list(object({
    rule_number = number
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules for NACL"
  type = list(object({
    rule_number = number
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}
