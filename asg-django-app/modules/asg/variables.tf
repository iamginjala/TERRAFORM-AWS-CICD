variable "ami_id" {
  type = string
  description = "ami id of the instance"
}

variable "instance_type" {
  type = string
  description = "instance type"
}
variable "asg_sg_id" {
  type = string
  description = "security group for auto scaling"
}

variable "private_subnet_ids" {
  description = "subnet ids to launch ec2 instances"
  type = list(string)
}

variable "target_arn" {
  description = "default target group arn"
  type = string
}

variable "min" {
  type = number
  default = 1
}
variable "max" {
  type = number
  default = 5
}
variable "desired" {
  type = number
  default = 2
}