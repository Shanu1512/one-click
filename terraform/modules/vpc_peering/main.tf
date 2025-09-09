# VPC Peering Connection
resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  auto_accept = true

  tags = {
    Name = "db-management-peering"
  }
}

# Routes from requester to accepter
resource "aws_route" "requester_to_accepter" {
  for_each                  = toset(var.requester_rt_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Routes from accepter to requester
resource "aws_route" "accepter_to_requester" {
  for_each                  = toset(var.accepter_rt_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.requester_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# # Security group ingress rules (requester)
# resource "aws_security_group_rule" "req_icmp" {
#   type              = "ingress"
#   from_port         = -1
#   to_port           = -1
#   protocol          = "icmp"
#   cidr_blocks       = [var.accepter_cidr]
#   security_group_id = var.requester_sg_id
# }

# # Security group ingress rules (accepter)
# resource "aws_security_group_rule" "acc_icmp" {
#   type              = "ingress"
#   from_port         = -1
#   to_port           = -1
#   protocol          = "icmp"
#   cidr_blocks       = [var.requester_cidr]
#   security_group_id = var.accepter_sg_id
# }
