# Public Route Tables
resource "aws_route_table" "public" {
  count  = length(var.public_subnets)
  vpc_id = var.vpc_id
  tags   = { Name = "public-rt-${count.index}" }
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = var.vpc_id
  tags   = { Name = "private-rt-${count.index}" }
}

# Associate public subnets
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = var.public_subnets[count.index]
  route_table_id = aws_route_table.public[count.index].id
}

# Associate private subnets
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = var.private_subnets[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

# Public route to IGW
resource "aws_route" "public_internet" {
  count                  = length(var.public_subnets)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# Private route to NAT
resource "aws_route" "private_nat" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_id
}
