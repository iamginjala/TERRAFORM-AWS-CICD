output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.load_balancer_arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}


output "load_dns" {
  value = module.alb.lb_dns
}