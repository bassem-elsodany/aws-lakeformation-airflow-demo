import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node User Data Catalog
UserDataCatalog_node1646856933021 = glueContext.create_dynamic_frame.from_catalog(
    database="lakeformation-airflow-demo-raw",
    table_name="source_tickit_saas_users",
    transformation_ctx="UserDataCatalog_node1646856933021",
)

# Script generated for node Sales Data Catalog
SalesDataCatalog_node1646857032433 = glueContext.create_dynamic_frame.from_catalog(
    database="lakeformation-airflow-demo-raw",
    table_name="source_tickit_sales",
    transformation_ctx="SalesDataCatalog_node1646857032433",
)

# Script generated for node Event Data Catalog
EventDataCatalog_node1646857081587 = glueContext.create_dynamic_frame.from_catalog(
    database="lakeformation-airflow-demo-raw",
    table_name="source_tickit_saas_event",
    transformation_ctx="EventDataCatalog_node1646857081587",
)

# Script generated for node Join user and sales
Joinuserandsales_node1646856951267 = Join.apply(
    frame1=UserDataCatalog_node1646856933021,
    frame2=SalesDataCatalog_node1646857032433,
    keys1=["userid"],
    keys2=["sellerid"],
    transformation_ctx="Joinuserandsales_node1646856951267",
)

# Script generated for node Select Fields
SelectFields_node1646857535025 = SelectFields.apply(
    frame=Joinuserandsales_node1646856951267,
    paths=[
        "firstname",
        "likeopera",
        "city",
        "likemusicals",
        "likesports",
        "likejazz",
        "userid",
        "lastname",
        "likeclassical",
        "likevegas",
        "liketheatre",
        "likerock",
        "phone",
        "likeconcerts",
        "state",
        "email",
        "likebroadway",
        "username",
        "listid",
        "saletime",
        "eventid",
        "salesid",
        "sellerid",
        "dateid",
        "commission",
        "qtysold",
        "buyerid",
    ],
    transformation_ctx="SelectFields_node1646857535025",
)

# Script generated for node Join
Join_node1646857095028 = Join.apply(
    frame1=EventDataCatalog_node1646857081587,
    frame2=SelectFields_node1646857535025,
    keys1=["eventid"],
    keys2=["eventid"],
    transformation_ctx="Join_node1646857095028",
)

# Script generated for node Apply Mapping
ApplyMapping_node1646858079310 = ApplyMapping.apply(
    frame=Join_node1646857095028,
    mappings=[
        ("eventid", "int", "eventid", "int"),
        ("catid", "short", "catid", "short"),
        ("venueid", "short", "venueid", "short"),
        ("dateid", "short", "dateid", "short"),
        ("starttime", "timestamp", "starttime", "timestamp"),
        ("eventname", "string", "eventname", "string"),
        ("firstname", "string", "firstname", "string"),
        ("likeopera", "boolean", "likeopera", "boolean"),
        ("city", "string", "city", "string"),
        ("likemusicals", "boolean", "likemusicals", "boolean"),
        ("likesports", "boolean", "likesports", "boolean"),
        ("likejazz", "boolean", "likejazz", "boolean"),
        ("userid", "int", "userid", "int"),
        ("lastname", "string", "lastname", "string"),
        ("likeclassical", "boolean", "likeclassical", "boolean"),
        ("likevegas", "boolean", "likevegas", "boolean"),
        ("liketheatre", "boolean", "liketheatre", "boolean"),
        ("likerock", "boolean", "likerock", "boolean"),
        ("phone", "string", "phone", "string"),
        ("likeconcerts", "boolean", "likeconcerts", "boolean"),
        ("state", "string", "state", "string"),
        ("email", "string", "email", "string"),
        ("likebroadway", "boolean", "likebroadway", "boolean"),
        ("username", "string", "username", "string"),
        ("listid", "int", "listid", "int"),
        ("saletime", "string", "saletime", "string"),
        ("`.eventid`", "int", "`.eventid`", "int"),
        ("salesid", "int", "salesid", "int"),
        ("sellerid", "int", "sellerid", "int"),
        ("`.dateid`", "short", "`.dateid`", "short"),
        ("commission", "decimal", "commission", "int"),
        ("qtysold", "short", "qtysold", "short"),
        ("buyerid", "int", "buyerid", "int"),
    ],
    transformation_ctx="ApplyMapping_node1646858079310",
)

# Script generated for node Amazon S3
AmazonS3_node1646857155738 = glueContext.getSink(
    path="s3://lakeformation-airflow-demo-processed/input/tickit/",
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=[],
    enableUpdateCatalog=True,
    transformation_ctx="AmazonS3_node1646857155738",
)
AmazonS3_node1646857155738.setCatalogInfo(
    catalogDatabase="lakeformation-airflow-demo-processed",
    catalogTableName="user_sales_event",
)
AmazonS3_node1646857155738.setFormat("glueparquet")
AmazonS3_node1646857155738.writeFrame(ApplyMapping_node1646858079310)
job.commit()
