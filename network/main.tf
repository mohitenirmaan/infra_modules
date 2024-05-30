resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support  = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    {
      "Name" = format("%s-vpc", var.name)
    },
    var.tags,
  )
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)  
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = merge(
    {
      "Name" = format("%s-public-subnet %d", var.name, count.index + 1)
    },
    var.tags,
  )
}
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zone_private[count.index]
  tags = merge(
    {
      "Name" = format("%s-%s-subnet %d",
        var.name,
        count.index < 2 ? "Application" : "Database",
        count.index % 2 + 1
      )
    },
    var.tags,
  )
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    {
      "Name" = format("%s-igw", var.name)
    },
    var.tags,
  )
}
resource "aws_eip" "static_IP" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.static_IP.id
    subnet_id = aws_subnet.public_subnet[0].id
}

resource "aws_route_table" "public_routeTable" {
  vpc_id =  aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    {
      "Name" = format("%s-pub-RT", var.name)
    },
    var.tags,
  )
}
resource "aws_route_table_association" "public_routeTable_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_routeTable.id
}

resource "aws_route_table" "private_routeTable" {
  vpc_id =  aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = merge(
    {
      "Name" = format("%s-pvt-RT", var.name)
    },
    var.tags,
  )
}
resource "aws_route_table_association" "private_routeTable_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_routeTable.id
}
