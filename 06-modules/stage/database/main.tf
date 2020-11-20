# define provider and region
provider "aws" {  
    region = "us-east-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state-ff"
    key            = "stage/database/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

module "database" {
  source = "../../modules/database"

  cluster_name           = "database-stage"
  db_name                = "mydatabase"
  db_password            = var.db_password
}

# to get teh output from module
output "port" {
  value = module.database.port
}

output "address" {
  value = module.database.address
}