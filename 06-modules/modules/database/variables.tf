# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "db_password" {
  description = "The password for the database"
  type        = string
  # do not add password here
  # before apply export the password
  # $  export TF_VAR_db_password="(YOUR_DB_PASSWORD)"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_name" {
  description = "The password for the database"
  type        = string
}