# ICMP (ping) allowed
resource "aws_security_group_rule" "accepter_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = var.accepter_sg_id
  source_security_group_id = var.requester_sg_id
}

resource "aws_security_group_rule" "requester_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = var.requester_sg_id
  source_security_group_id = var.accepter_sg_id
}


# All protocols
resource "aws_security_group_rule" "requester_all" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  security_group_id        = var.requester_sg_id
  source_security_group_id = var.accepter_sg_id
}

resource "aws_security_group_rule" "accepter_all" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  security_group_id        = var.accepter_sg_id
  source_security_group_id = var.requester_sg_id
}
