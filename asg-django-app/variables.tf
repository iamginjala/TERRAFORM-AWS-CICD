variable "region" {
  type = string
  description = "region for the account"
}

variable "cidr_block" {
  type = string
}
variable "public_subnet_count" {
  type = number
}
variable "private_subnet_count" {
  type = number
}

variable "public_subnet_cidr" {
  type = list(string)
  description = "public subnet range"
}

variable "private_subnet_cidr" {
  type = list(string)
  description = "private subnet range"
}

variable "az" {
  type = list(string)
  description = "availability zones for the region"
}



variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}