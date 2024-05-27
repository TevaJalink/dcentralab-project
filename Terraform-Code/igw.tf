resource "aws_internet_gateway" "Internet_Gateway" {
  vpc_id = aws_vpc.Application_VPC.id

  tags = {
    Name = "${var.Internet_Gateway_Name}"
  }
}