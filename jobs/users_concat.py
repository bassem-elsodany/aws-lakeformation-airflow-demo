import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrameCollection
from awsglue.dynamicframe import DynamicFrame

def MyTransform(glueContext, dfc) -> DynamicFrameCollection:
    newdf = dfc.select(list(dfc.keys())[0]).toDF()
    
    from pyspark.sql import functions as sf
    newdf = newdf.withColumn('userfullname', sf.concat(sf.col('firstname'),sf.lit(' '), sf.col('lastname')))
    
    newdatedata = DynamicFrame.fromDF(newdf, glueContext, "newdatedata")
    return DynamicFrameCollection({"CustomTransform0": newdatedata}, glueContext)

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "lakeformation-airflow-demo-raw", table_name = "source_tickit_saas_users", transformation_ctx = "DataSource0"]
## @return: DataSource0
## @inputs: []
DataSource0 = glueContext.create_dynamic_frame.from_catalog(database = "lakeformation-airflow-demo-raw", table_name = "source_tickit_saas_users", transformation_ctx = "DataSource0")
## @type: CustomCode
## @args: [dynamicFrameConstruction = DynamicFrameCollection({"DataSource0": DataSource0}, glueContext), className = MyTransform, transformation_ctx = "Transform1"]
## @return: Transform1
## @inputs: [dfc = DataSource0]
Transform1 = MyTransform(glueContext, DynamicFrameCollection({"DataSource0": DataSource0}, glueContext))
## @type: SelectFromCollection
## @args: [key = list(Transform1.keys())[0], transformation_ctx = "Transform0"]
## @return: Transform0
## @inputs: [dfc = Transform1]
Transform0 = SelectFromCollection.apply(dfc = Transform1, key = list(Transform1.keys())[0], transformation_ctx = "Transform0")
## @type: DataSink
## @args: [connection_type = "s3", catalog_database_name = "lakeformation-airflow-demo-processed", format = "glueparquet", connection_options = {"path": "s3://lakeformation-airflow-demo-processed/input/tickit/", "partitionKeys": [], "enableUpdateCatalog":true, "updateBehavior":"UPDATE_IN_DATABASE"}, catalog_table_name = "users", transformation_ctx = "DataSink0"]
## @return: DataSink0
## @inputs: [frame = Transform0]
DataSink0 = glueContext.getSink(path = "s3://lakeformation-airflow-demo-processed/input/tickit/", connection_type = "s3", updateBehavior = "UPDATE_IN_DATABASE", partitionKeys = [], enableUpdateCatalog = True, transformation_ctx = "DataSink0")
DataSink0.setCatalogInfo(catalogDatabase = "lakeformation-airflow-demo-processed",catalogTableName = "users")
DataSink0.setFormat("glueparquet")
DataSink0.writeFrame(Transform0)

job.commit()