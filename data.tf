# Getting Latest Ubuntu AMI ID
data "aws_ami" "latest" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server*"]
  }
}

data "aws_availability_zones" "available" {}
