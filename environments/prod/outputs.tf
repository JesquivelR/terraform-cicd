output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "value of the VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "value of the public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "value of the private subnet IDs"
}

output "alb_dns_name" {
  value       = module.ec2.alb_dns_name
  description = "value of the ALB DNS name"
}