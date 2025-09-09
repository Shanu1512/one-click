aws_region         = "us-east-1"
vpc_cidr           = "10.1.0.0/16"
public_subnets     = ["10.1.1.0/24"]
private_subnets    = ["10.1.101.0/24"]
availability_zones = ["us-east-1a"]
key_name           = "tfkey"
ami = "ami-0c94855ba95c71c99" # example Ubuntu AMI
instance_type      = "t3.micro"
peer_vpc_id        = module.vpc.vpc_id # Jenkins VPC ID
jenkins_vpc_id     = "vpc-0cc69505ff3d3c354"
jenkins_vpc_cidr   = "10.0.0.0/24"
jenkins_rt_ids     = ["rtb-0b32a16eee5702eb1"]
jenkins_sg_id      = "sg-0d00c4cb620c9a0af"

