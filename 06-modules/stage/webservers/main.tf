# define provider and region
provider "aws" {  
    region = "us-east-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state-ff"
    key            = "stage/webservers/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../../modules/webservers"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-ff"
  db_remote_state_key    = "stage/database/terraform.tfstate"
}

# to get teh output from module
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}