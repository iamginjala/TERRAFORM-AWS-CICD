module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.cidr_block
  az = var.az
  private_subnet_count = var.private_subnet_count
  public_subnet_count = var.public_subnet_count
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
}
data aws_ami "amazon_linux" {
    most_recent = true
    owners  =  ["amazon"]

    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}


module "sg" {
    source = "./modules/security_groups"
    vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"
  alb_sg_id = module.sg.alb_sg_id
  public_subnet_id = module.vpc.public_subnet_ids
  vpc_id = module.vpc.vpc_id
}

module "asg" {
  source = "./modules/asg"
  instance_type = var.instance_type
  target_arn = module.alb.target_group_arn
  ami_id = data.aws_ami.amazon_linux.id
  asg_sg_id = module.sg.asg_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}