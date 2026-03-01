output "target_group_arn" {
  value = aws_lb_target_group.test_target.arn
}
output "load_balancer_arn" {
  value = aws_lb.test.arn
}
output "lb_dns" {
  value = aws_lb.test.dns_name
}