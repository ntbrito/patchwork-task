resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.avail_zones[count.index]
  cidr_block = cidrsubnet(var.cidr, 3, count.index)
  tags = {
    Name = "public subnet ${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.avail_zones[count.index]
  cidr_block = cidrsubnet(var.cidr, 3, count.index + 2)
  tags = {
    Name = "private subnet ${count.index}"
  }
}
