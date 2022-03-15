import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "lakeformation-airflow-demo-processed", table_name = "users", transformation_ctx = "DataSource0"]
## @return: DataSource0
## @inputs: []
DataSource0 = glueContext.create_dynamic_frame.from_catalog(database = "lakeformation-airflow-demo-processed", table_name = "users", transformation_ctx = "DataSource0")
## @type: DataSource
## @args: [database = "lakeformation-airflow-demo-raw", table_name = "source_tickit_sales", transformation_ctx = "DataSource1"]
## @return: DataSource1
## @inputs: []
DataSource1 = glueContext.create_dynamic_frame.from_catalog(database = "lakeformation-airflow-demo-raw", table_name = "source_tickit_sales", transformation_ctx = "DataSource1")
## @type: Join
## @args: [keys2 = ["sellerid"], keys1 = ["userid"], transformation_ctx = "Transform2"]
## @return: Transform2
## @inputs: [frame1 = DataSource0, frame2 = DataSource1]
Transform2 = Join.apply(frame1 = DataSource0, frame2 = DataSource1, keys2 = ["sellerid"], keys1 = ["userid"], transformation_ctx = "Transform2")
## @type: SelectFields
## @args: [paths = ["firstname", "likeopera", "city", "likemusicals", "likesports", "likejazz", "userid", "lastname", "likeclassical", "likevegas", "liketheatre", "likerock", "phone", "likeconcerts", "state", "email", "likebroadway", "username", "listid", "saletime", "eventid", "salesid", "sellerid", "dateid", "commission", "qtysold", "buyerid", "userfullname"], transformation_ctx = "Transform1"]
## @return: Transform1
## @inputs: [frame = Transform2]
Transform1 = SelectFields.apply(frame = Transform2, paths = ["firstname", "likeopera", "city", "likemusicals", "likesports", "likejazz", "userid", "lastname", "likeclassical", "likevegas", "liketheatre", "likerock", "phone", "likeconcerts", "state", "email", "likebroadway", "username", "listid", "saletime", "eventid", "salesid", "sellerid", "dateid", "commission", "qtysold", "buyerid", "userfullname"], transformation_ctx = "Transform1")
## @type: ApplyMapping
## @args: [mappings = [("firstname", "string", "firstname", "string"), ("likeopera", "boolean", "likeopera", "boolean"), ("city", "string", "city", "string"), ("likemusicals", "boolean", "likemusicals", "boolean"), ("likesports", "boolean", "likesports", "boolean"), ("likejazz", "boolean", "likejazz", "boolean"), ("userid", "int", "userid", "int"), ("lastname", "string", "lastname", "string"), ("likeclassical", "boolean", "likeclassical", "boolean"), ("likevegas", "boolean", "likevegas", "boolean"), ("liketheatre", "boolean", "liketheatre", "boolean"), ("likerock", "boolean", "likerock", "boolean"), ("phone", "string", "phone", "string"), ("likeconcerts", "boolean", "likeconcerts", "boolean"), ("state", "string", "state", "string"), ("email", "string", "email", "string"), ("likebroadway", "boolean", "likebroadway", "boolean"), ("username", "string", "username", "string"), ("userfullname", "string", "userfullname", "string"), ("listid", "int", "listid", "int"), ("saletime", "string", "saletime", "string"), ("eventid", "int", "eventid", "int"), ("salesid", "int", "salesid", "int"), ("sellerid", "int", "sellerid", "int"), ("dateid", "short", "dateid", "short"), ("commission", "decimal", "commission", "int"), ("qtysold", "short", "qtysold", "short"), ("buyerid", "int", "buyerid", "int")], transformation_ctx = "Transform0"]
## @return: Transform0
## @inputs: [frame = Transform1]
Transform0 = ApplyMapping.apply(frame = Transform1, mappings = [("firstname", "string", "firstname", "string"), ("likeopera", "boolean", "likeopera", "boolean"), ("city", "string", "city", "string"), ("likemusicals", "boolean", "likemusicals", "boolean"), ("likesports", "boolean", "likesports", "boolean"), ("likejazz", "boolean", "likejazz", "boolean"), ("userid", "int", "userid", "int"), ("lastname", "string", "lastname", "string"), ("likeclassical", "boolean", "likeclassical", "boolean"), ("likevegas", "boolean", "likevegas", "boolean"), ("liketheatre", "boolean", "liketheatre", "boolean"), ("likerock", "boolean", "likerock", "boolean"), ("phone", "string", "phone", "string"), ("likeconcerts", "boolean", "likeconcerts", "boolean"), ("state", "string", "state", "string"), ("email", "string", "email", "string"), ("likebroadway", "boolean", "likebroadway", "boolean"), ("username", "string", "username", "string"), ("userfullname", "string", "userfullname", "string"), ("listid", "int", "listid", "int"), ("saletime", "string", "saletime", "string"), ("eventid", "int", "eventid", "int"), ("salesid", "int", "salesid", "int"), ("sellerid", "int", "sellerid", "int"), ("dateid", "short", "dateid", "short"), ("commission", "decimal", "commission", "int"), ("qtysold", "short", "qtysold", "short"), ("buyerid", "int", "buyerid", "int")], transformation_ctx = "Transform0")
## @type: DataSink
## @args: [connection_type = "s3", catalog_database_name = "lakeformation-airflow-demo-processed", format = "glueparquet", connection_options = {"path": "s3://lakeformation-airflow-demo-processed/input/tickit/", "partitionKeys": [], "enableUpdateCatalog":true, "updateBehavior":"UPDATE_IN_DATABASE"}, catalog_table_name = "user_sales", transformation_ctx = "DataSink0"]
## @return: DataSink0
## @inputs: [frame = Transform0]
DataSink0 = glueContext.getSink(path = "s3://lakeformation-airflow-demo-processed/input/tickit/", connection_type = "s3", updateBehavior = "UPDATE_IN_DATABASE", partitionKeys = [], enableUpdateCatalog = True, transformation_ctx = "DataSink0")
DataSink0.setCatalogInfo(catalogDatabase = "lakeformation-airflow-demo-processed",catalogTableName = "user_sales")
DataSink0.setFormat("glueparquet")
DataSink0.writeFrame(Transform0)

job.commit()