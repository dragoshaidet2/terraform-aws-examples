resource "aws_db_instance" "example" {
  identifier_prefix   = "${var.cluster_name}-id"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"

  username            = "admin"

  name                = var.db_name
  skip_final_snapshot = true

  password            = var.db_password
}
