resource "aws_vpc" "Application_VPC" {
  cidr_block = var.VPC_CIDR_Block

  tags = {
    Name = "${var.VPC_Name}"
  }
}