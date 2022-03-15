# lakeformation-airflow-demo

## Architecture landscape
![plot](images/landscape.png)

## mysql DB
![plot](images/mysql-tickit.png)

## postgresql DB
![plot](images/postgre-tickit.png)

#### [1] execute to prepare the env

> export AWS_DEFAULT_REGION=eu-west-2 \
  export AWS_DEFAULT_PROFILE=development


#### [2] execute the infrastructure

> terraform init \
> terraform apply -auto-approve \
> terraform show -json


#### [3] Create the blueprint
##### [3.1] login using created lake admin user lakeformation-airflow-demo-admin-user
##### [3.2] create lakeformation blueprints[ AWS Lake Formation > Blueprints]
###### lakeformation mysql blueprint
![plot](images/mysql_blueprint.png)

###### lakeformation postgresql blueprint
![plot](images/postgresql_blueprint.png)


#### [4] Orchestrate DAGS
##### [4.1] execute dags from MWAA UI
![plot](images/mwaa_dags_execute.png)

##### [4.2] check the blueprint workflow runing status and make sure it's completed
![plot](images/lakeformation_wf.png)

#### [5] check Lake databases tables
##### [5.1] Raw Lake databases tables
![plot](images/lakeformation_raw.png)

##### [5.2] Processed Lake databases tables
![plot](images/lakeformation_processed.png)

#### [5] Athena Queries
##### [5.1] query processed user table in processed catalog
![plot](images/athena_users_processed.png)

##### [5.2] query join tables of user and sales tables in processed catalog
![plot](images/athena_users_sales_processed.png)