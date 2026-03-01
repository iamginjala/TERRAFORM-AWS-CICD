variable "cidr_block" {
  type = string
  description = "cidr block for entire vpc"
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


variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
}