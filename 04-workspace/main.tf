# define provider and region
provider "aws" {  
    region = "us-east-1"
}

# using backend s3 and dynamodb created before
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state-ff"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

# define variable for server port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# ec2 spot instance
resource "aws_spot_instance_request" "example" {
  # ubuntu 20.04 LTS ami-070062dd89dbb7eba
  ami           = "ami-070062dd89dbb7eba"
  instance_type = "t2.micro"
  spot_price    = "0.005"

  tags = {
    Name = "terraform-example"
  }
}

# to show workspace
# $ terraform workspace show
# create new workspace: 
# $ terraform workspace new example1
# list workspace
# $ terraform workspace list
# switch to workspace 
# $ terraform workspace select example1
# each workspace will create a new EC2 spot instance in this example

