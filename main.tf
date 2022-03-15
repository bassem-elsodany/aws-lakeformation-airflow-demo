locals {
  name   = "lakeformation-airflow-demo"
  region = "eu-west-2"
  environment = "development"
  bu = "IT"
  rds_db_name  = "tickit"

  s3_buckets = ["lakeformation-airflow-demo-raw","lakeformation-airflow-demo-processed","lakeformation-airflow-demo-curated"]
  s3_athena_query_bucket = "lakeformation-athena-saved-queries"
  s3_glue_jobs_bucket = "lakeformation-glue-jobs"
  
  s3_mwaa_bucket = "lakeformation-mwaa"
  s3_mwaa_bucket_structure  = ["dags"]
  mwaa_environment_name= "MyAirflowEnvironment-demo"
  
  s3_buckets_raw_structure = ["input/tickit/mysql","input/tickit/postgresql"]
  s3_buckets_processed_structure = ["input/tickit"]
  s3_buckets_curated_structure = ["input/tickit"]

  
  lakeformation_databases = ["lakeformation-airflow-demo-raw","lakeformation-airflow-demo-processed","lakeformation-airflow-demo-curated"]

  tags = {
    Owner       = "lakeformation"
    Environment = "development"
    BU = "IT"
  }
}

data "aws_caller_identity" "current" {}