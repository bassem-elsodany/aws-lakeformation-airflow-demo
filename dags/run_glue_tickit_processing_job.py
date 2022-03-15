import os
from datetime import timedelta

from airflow import DAG
from airflow.models.baseoperator import chain
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.providers.amazon.aws.operators.glue import AwsGlueJobOperator
from airflow.utils.dates import days_ago

DAG_ID = os.path.basename(__file__).replace(".py", "")

DEFAULT_ARGS = {
    "owner": "bassemElsodany",
    "depends_on_past": False,
    "retries": 0,
    "email_on_failure": False,
    "email_on_retry": False,
}

with DAG(
    dag_id=DAG_ID,
    description="Run AWS Glue Postgresql Workflow - lakeformation-airflow-demo-raw to lakeformation-airflow-demo-processed data",
    default_args=DEFAULT_ARGS,
    dagrun_timeout=timedelta(minutes=5),
    start_date=days_ago(1),
    schedule_interval=None,
    tags=["lakeformation-airflow-demo", "lakeformation-airflow-demo-processed"],
) as dag:
    begin = DummyOperator(task_id="begin")

    end = DummyOperator(task_id="end")

    list_source_glue_tables = BashOperator(
        task_id="list_source_glue_tables",
        bash_command="""aws glue get-tables --database-name lakeformation-airflow-demo-raw \
                          --query 'TableList[].Name' --expression "source_*"  \
                          --output table""",
    )

    list_target_glue_tables = BashOperator(
        task_id="list_target_glue_tables",
        bash_command="""aws glue get-tables --database-name lakeformation-airflow-demo-processed \
                          --query 'TableList[].Name' --expression "*"  \
                          --output table""",
    )

    start_users_concat_job = AwsGlueJobOperator(
            task_id=f"users_concat_job", job_name=f"users_concat_job"
    )

    start_joining_job = AwsGlueJobOperator(
            task_id=f"event_user_sales_combined_job", job_name=f"event_user_sales_combined_job"
    )

chain(
    begin,
    list_source_glue_tables,
    start_users_concat_job,
    start_joining_job,
    list_target_glue_tables,
    end,
)
