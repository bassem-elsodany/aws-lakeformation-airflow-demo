WITH a AS 
    (SELECT * FROM "AwsDataCatalog"."lakeformation-airflow-demo-processed"."users"),
b as (SELECT * FROM "AwsDataCatalog"."lakeformation-airflow-demo-raw"."source_tickit_sales")

SELECT * FROM a
INNER JOIN b ON a.userid=b.sellerid limit 20;