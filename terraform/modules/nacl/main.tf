# # Placeholder NACL module
# resource "aws_network_acl" "this" {
#   vpc_id = var.vpc_id
#   tags   = { Name = var.name }
# }
resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id
  tags   = { Name = var.name }
}

resource "aws_network_acl_rule" "ingress" {
  for_each       = { for r in var.ingress_rules : r.rule_number => r }
  network_acl_id = aws_network_acl.this.id
  rule_number    = each.value.rule_number
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  egress         = false
}

resource "aws_network_acl_rule" "egress" {
  for_each       = { for r in var.egress_rules : r.rule_number => r }
  network_acl_id = aws_network_acl.this.id
  rule_number    = each.value.rule_number
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  egress         = true
}

resource "aws_network_acl_association" "this" {
  for_each = { for idx, subnet_id in var.subnet_ids : idx => subnet_id }

  subnet_id    = each.value
  network_acl_id = aws_network_acl.this.id
}
