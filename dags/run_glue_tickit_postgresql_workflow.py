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
    description="Run AWS Glue Postgresql Workflow - source data to lakeformation-airflow-demo-raw data",
    default_args=DEFAULT_ARGS,
    dagrun_timeout=timedelta(minutes=5),
    start_date=days_ago(1),
    schedule_interval=None,
    tags=["lakeformation-airflow-demo", "lakeformation-airflow-demo-raw"],
) as dag:
    begin = DummyOperator(task_id="begin")

    end = DummyOperator(task_id="end")

    list_glue_tables = BashOperator(
        task_id="list_glue_tables",
        bash_command="""aws glue get-tables --database-name lakeformation-airflow-demo-raw \
                          --query 'TableList[].Name' --expression "source_*"  \
                          --output table""",
    )

    run_glue_postgresql_workflow = BashOperator(
        task_id="run_glue_postgresql_workflow",
        bash_command="""aws glue start-workflow-run --name tickit_postgresql_source_wf""",
    )    


chain(
    begin,
    run_glue_postgresql_workflow,
    list_glue_tables,
    end,
)
