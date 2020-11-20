
variable "db_password" {
  description = "The password for the database"
  type        = string
  # do not add password here
  # before apply export the password
  # $  export TF_VAR_db_password="(YOUR_DB_PASSWORD)"
}

