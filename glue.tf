################################################################################
# GLUE CONNECTIONS
################################################################################

# Mysql
resource "aws_glue_connection" "mysql_connection" {

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${module.mysql-db.db_instance_endpoint}/${local.rds_db_name}"
    PASSWORD            = module.mysql-db.db_instance_password
    USERNAME            = module.mysql-db.db_instance_username
  }

  name = "tickit_mysql_source"

  physical_connection_requirements {
    availability_zone      = "${local.region}a"
    security_group_id_list = [module.db_security_group.security_group_id]
    subnet_id              = tolist(module.vpc.database_subnets)[0]
  }
}

# Postgresql
resource "aws_glue_connection" "postgresql_connection" {

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${module.postgres-db.db_instance_endpoint}/${local.rds_db_name}"
    PASSWORD            = module.postgres-db.db_instance_password
    USERNAME            = module.postgres-db.db_instance_username
  }

  name = "tickit_postgresql_source"

  physical_connection_requirements {
    availability_zone      = "${local.region}b"
    security_group_id_list = [module.db_security_group.security_group_id]
    subnet_id              = tolist(module.vpc.database_subnets)[1]
  }
}
################################################################################
# GLUE JOBS
################################################################################
resource "aws_glue_job" "users_concat" {
  name     = "users_concat_job"
  role_arn = module.iam_assumable_role_lakeformation.iam_role_arn
  max_retries = 0
  glue_version="3.0"
  number_of_workers =2
  worker_type="G.1X"
  command {
    script_location = "s3://${aws_s3_bucket.datalake_s3_glue_jobs_bucket.id}/users_concat.py"
  }
}


resource "aws_glue_job" "user_sales_combined" {
  name     = "user_sales_combined_job"
  role_arn = module.iam_assumable_role_lakeformation.iam_role_arn
  max_retries = 0
  glue_version="3.0"
  number_of_workers =2
  worker_type="G.1X"

  command {
    script_location = "s3://${aws_s3_bucket.datalake_s3_glue_jobs_bucket.id}/user_sales_combined.py"
  }
}