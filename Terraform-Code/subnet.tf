resource "aws_subnet" "public-subnet" {
  count             = length(var.Public_Subnets)
  vpc_id            = aws_vpc.Application_VPC.id
  cidr_block        = var.Public_Subnets[count.index]
  availability_zone = var.Availability_Zones[count.index]

  tags = {
    "Name" = "Public-Subnet-${var.Availability_Zones[count.index]}"
  }
}