# -----------------------------
# VPC
# -----------------------------
output "vpc_id" {
  value = module.vpc.vpc_id
}

# -----------------------------
# Subnets
# -----------------------------
output "public_subnets" {
  value = module.subnet.public_subnet_ids
}

output "private_subnets" {
  value = module.subnet.private_subnet_ids
}

# -----------------------------
# NAT
# -----------------------------
output "nat_id" {
  value = module.nat.nat_id
}

# -----------------------------
# Route Tables
# -----------------------------
output "public_rt_ids" {
  value = module.route_tables.public_rt_ids
}

output "private_rt_ids" {
  value = module.route_tables.private_rt_ids
}

output "igw_id" {
  value = module.igw.igw_id
}

# -----------------------------
# Security Groups
# -----------------------------
output "db_sg_id" {
  value = module.db_sg.sg_id
}

output "bastion_sg_id" {
  value = module.bastion_sg.sg_id
}

# -----------------------------
# EC2 Instances
# -----------------------------
output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "db_master_private_ip" {
  value = module.db_master.private_ip
}

# -----------------------------
# VPC Peering
# -----------------------------
output "vpc_peering_id" {
  description = "VPC Peering Connection ID between mgmt-vpc and jenkins-vpc"
  value       = module.vpc_peering.vpc_peering_id
}
