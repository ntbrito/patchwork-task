resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "Public Routes"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  count  = 2

  tags = {
    Name = "Private Routes"
  }
}

resource "aws_route" "public_internet" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_default_route_table.public.id
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_default_route_table.public.id
  count          = 2
}
