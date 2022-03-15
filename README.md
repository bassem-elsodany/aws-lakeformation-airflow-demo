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

#### [5] check Lake databases tables
![plot](images/lakeformation_tables.png)