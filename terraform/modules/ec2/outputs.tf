output "public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP of the instance"
  value       = aws_instance.this.private_ip
}
