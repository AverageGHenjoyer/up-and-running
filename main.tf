provider "aws" {
  region = "eu-north-1"
}
resource "aws_instance" "example" {
  ami = "ami-0989fb15ce71ba39e"
  instance_type = "t3.micro"

  tags = {
    Name = "Terraform-example"
  }
}