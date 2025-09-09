# Allow all ICMP (ping) from Accepter VPC to Requester SG
resource "aws_security_group_rule" "requester_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.accepter_cidr]
  security_group_id = var.requester_sg_id
}

# Allow all ICMP (ping) from Requester VPC to Accepter SG
resource "aws_security_group_rule" "accepter_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.requester_cidr]
  security_group_id = var.accepter_sg_id
}

# -----------------------------
# TCP rules (allow all ports)
# -----------------------------

# Allow all TCP from Accepter VPC to Requester SG
resource "aws_security_group_rule" "requester_tcp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "tcp"
  cidr_blocks       = [var.accepter_cidr]
  security_group_id = var.requester_sg_id
}

# Allow all TCP from Requester VPC to Accepter SG
resource "aws_security_group_rule" "accepter_tcp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "tcp"
  cidr_blocks       = [var.requester_cidr]
  security_group_id = var.accepter_sg_id
}
