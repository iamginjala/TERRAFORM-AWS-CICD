variable "alb_sg_id" {
  type = string
  description = "alb sg"
}
variable "public_subnet_id" {
  type = list(string)
  description = "public subnet ids"
}
variable "vpc_id" {
  type  = string
  description = "vpc id for the subnet"
}
