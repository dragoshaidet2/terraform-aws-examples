# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node 
provider "aws" {
  region = "us-east-1"
}

# ubuntu 20.04 LTS ami-089e6b3b328e5a2c1
resource "aws_instance" "example" {
  ami           = "ami-089e6b3b328e5a2c1"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-example"
  }
}