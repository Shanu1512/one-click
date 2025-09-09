# -----------------------------
# VPC
# -----------------------------
module "vpc" {
  source     = "./modules/vpc"
  name       = "db-vpc"
  cidr_block = var.vpc_cidr
}

# -----------------------------
# Subnets
# -----------------------------
module "subnet" {
  source             = "./modules/subnet"
  name               = "db-subnet"
  vpc_id             = module.vpc.vpc_id
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  map_public_ip      = true
}

# IGW
# Create Internet Gateway
module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
  name   = "db-igw"
}
# -----------------------------
# NAT Gateway
# -----------------------------
module "nat" {
  source           = "./modules/nat"
  public_subnet_id = module.subnet.public_subnet_ids[0]
}

# -----------------------------
# Route Tables
# -----------------------------
# Route Tables
module "route_tables" {
  source          = "./modules/route_table"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.subnet.public_subnet_ids
  private_subnets = module.subnet.private_subnet_ids
  igw_id          = module.igw.igw_id
  nat_id          = module.nat.nat_id
}

# Security Groups
# -----------------------------
module "db_sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "db-sg"
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.1.0.0/16"] },
    { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.1.0.0/16"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["10.1.0.0/16"] }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "bastion_sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "mgmt-bastion-sg"
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}


# Fetch latest Ubuntu 22.04 AMI in us-east-1
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# -----------------------------
# EC2 Instances
# -----------------------------
module "bastion" {
  source              = "./modules/ec2"
  name                = "bastion-host"
  ami_id              = data.aws_ami.ubuntu_2204.id
  instance_type       = "t3.micro"
  subnet_id           = element(module.subnet.public_subnet_ids, 0)
  key_name            = var.key_name
  security_group_ids  = [module.bastion_sg.sg_id]
  associate_public_ip = true
  tags                = { Environment = "dev" 
  Role                = "bastion" }
}

module "db_master" {
  source              = "./modules/ec2"
  name                = "db-master"
  ami_id              = data.aws_ami.ubuntu_2204.id
  instance_type       = var.instance_type
  subnet_id           = module.subnet.private_subnet_ids[0]
  key_name            = var.key_name
  security_group_ids  = [module.db_sg.sg_id]
  associate_public_ip = false
  tags                = { Environment = "prod" 
  Role                = "db-master" }
}

# -----------------------------
# VPC Peering
# -----------------------------
resource "aws_vpc_peering_connection" "this" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true
}

module "vpc_peering" {
  source = "./modules/vpc_peering"

  requester_vpc_id = module.vpc.vpc_id
  accepter_vpc_id  = var.jenkins_vpc_id

  requester_cidr = var.vpc_cidr
  accepter_cidr  = var.jenkins_vpc_cidr

  requester_rt_ids = module.route_tables.private_rt_ids  # private RT in mgmt-vpc
  accepter_rt_ids  = var.jenkins_rt_ids                 # RTs from Jenkins VPC

  requester_sg_id = module.db_sg.sg_id
  accepter_sg_id  = var.jenkins_sg_id
}

