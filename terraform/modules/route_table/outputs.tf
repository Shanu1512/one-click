# Public Route Table
output "public_rt_ids" {
  value       = aws_route_table.public[*].id
  description = "ID of the public route table"
}

# Private Route Table
output "private_rt_ids" {
  value       = aws_route_table.private[*].id
  description = "ID of the private route table"
}
