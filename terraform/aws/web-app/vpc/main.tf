#create new virtual private network
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main"
  }
}
#set a public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  cidr_block = var.public_subnet_cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-${count.index}"
  }
}
#set private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  cidr_block = var.private_subnet_cidr_blocks[count.index]
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-${count.index}"
  }
}
#set net gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
#set routing table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

  tags = {
    Name = "public"
  }
}
