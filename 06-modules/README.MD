1. go to global folder and initiate the remote state s3 and dynamodb locks. You need to change the s3 name
   ```
   $ terraform init
   $ terraform apply
   ```
2. go to stage database and create db
   - before creating db export the pass 
   ```
   $ export TF_VAR_db_password="(YOUR_DB_PASSWORD)
   $ terraform init
   $ terraform apply
   ```
3. got to stage webservers and create webserver
   ```
   $ terraform init
   $ terraform apply
   ```