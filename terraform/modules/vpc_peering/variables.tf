variable "requester_vpc_id" { type = string }
variable "accepter_vpc_id"  { type = string }
variable "requester_cidr"   { type = string }
variable "accepter_cidr"    { type = string }
variable "requester_rt_ids" { type = list(string) }
variable "accepter_rt_ids"  { type = list(string) }
variable "requester_sg_id"  { type = string }
variable "accepter_sg_id"   { type = string }
