region = "us-east-2"
cidr_block = "10.0.0.0/16"
public_subnet_count = 2
private_subnet_count = 2
az = [ "us-east-2a","us-east-2b" ]
public_subnet_cidr = [ "10.0.1.0/24","10.0.2.0/24" ]
private_subnet_cidr = [ "10.0.11.0/24","10.0.12.0/24" ]
instance_type = "t2.micro"