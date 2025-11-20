import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext

# -------------------------
# Read Job Arguments
# -------------------------
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'raw_bucket',
    'redshift_workgroup',
    'redshift_db',
    'redshift_table',
    'redshift_temp_dir'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# -------------------------
# Read JSON array from S3
# -------------------------
raw_path = f"s3://{args['raw_bucket']}/"

df = spark.read.json(raw_path, multiLine=True)

print("Detected columns:", df.columns)
df.show(5, truncate=False)

# -------------------------
# Basic Transformations
# -------------------------
transformed = df.select(
    "id",
    "name",
    "username",
    "email",
    "phone",
    "website"
)

# -------------------------
# Convert Spark DataFrame -> DynamicFrame
# -------------------------
dynamic_frame = DynamicFrame.fromDF(
    transformed,
    glueContext,
    "transformed_df"
)

# -------------------------
# Write to Redshift Serverless
# -------------------------
glueContext.write_dynamic_frame.from_jdbc_conf(
    frame=dynamic_frame,
    catalog_connection="redshift-serverless",
    connection_options={
        "dbtable": args['redshift_table'],
        "database": args['redshift_db'],
        "workgroupName": args['redshift_workgroup']
    },
    redshift_tmp_dir=args['redshift_temp_dir'],
    transformation_ctx="redshift_write"
)

job.commit()
