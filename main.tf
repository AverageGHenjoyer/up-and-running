provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "the port the server will use for HTTP request"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0989fb15ce71ba39e"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag{
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default"{
  filter{
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}