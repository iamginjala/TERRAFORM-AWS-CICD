output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "asg_ids" {
  value = aws_security_group.asg_sg.id
}