resource "aws_vpc" "django_vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.django_vpc.id
  cidr_block = element(var.public_subnet_cidr,count.index)
  availability_zone = element(var.az,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.django_vpc.id
  cidr_block = element(var.private_subnet_cidr,count.index)
  availability_zone = element(var.az,count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.django_vpc.id

}
resource "aws_eip" "main_eip" {
  count = var.private_subnet_count
  domain = "vpc"
  tags = {
    Name = "nat-eip-az-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.private_subnet_count
  subnet_id = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.main_eip[count.index].id
  tags = {
    Name = "nat-gateway-az-${count.index + 1}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.django_vpc.id
  tags = {
    Name = "Public route table"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "private" {
 count = var.private_subnet_count 
 vpc_id = aws_vpc.django_vpc.id
 tags = {
    Name = "Private-route-table-${count.index +1} "
 } 
}
resource "aws_route" "private" {
    count = var.private_subnet_count
    route_table_id = aws_route_table.private[count.index].id
    nat_gateway_id = aws_nat_gateway.main[count.index].id
    destination_cidr_block = "0.0.0.0/0"
  
}

resource "aws_route_table_association" "private" {
  count = var.private_subnet_count
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}