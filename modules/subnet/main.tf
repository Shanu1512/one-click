resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnets : idx => cidr }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.availability_zones[each.key]
  map_public_ip_on_launch = var.map_public_ip
  tags = {
    Name = "${var.name}-public-${each.key}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnets : idx => cidr }
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]
  tags = {
    Name = "${var.name}-private-${each.key}"
  }
}
