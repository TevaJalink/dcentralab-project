resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.Application_VPC.id

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public-route-routing-table" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Internet_Gateway.id
}

resource "aws_route_table_association" "public-subnet" {
  count          = length(aws_subnet.public-subnet)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}