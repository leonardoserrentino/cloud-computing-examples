output "vpc_id" {
  description = "VPD ID"
  value       = aws_vpc.main.id
}

output "bastion_public_ip" {
  description = "Public IP address to connect to Bastion"
  value       = aws_instance.bastion.public_ip
}
