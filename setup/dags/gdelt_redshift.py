from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.sensors.s3_key_sensor import S3KeySensor
from airflow.operators.postgres_operator import PostgresOperator
from operators.s3_to_redshift_operator import S3ToRedshiftTransfer
from datetime import datetime, timedelta, date

default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': datetime(2019, 6, 12),
    'retries': 2,
    'retry_delay': timedelta(hours=1),
    'email': ["airflow@airflow.com"],
    'email_on_failure': False,
    'email_on_retry': False,
}
 
dag = DAG(dag_id='gdelt_redshift',
          default_args=default_args,
          schedule_interval='@daily',
          default_view='graph',
          max_active_runs=1)

# filename example - YYYYMMDD
bucket_key_template = 's3://gdelt-open-data/events/{}.export.csv'.format('{{ yesterday_ds_nodash }}')

file_sensor = S3KeySensor(
 task_id='s3_key_sensor_task',
 poke_interval=60 * 30, # (seconds); checking file every half an hour
 timeout=60 * 60 * 36, # timeout in  hours
 bucket_key=bucket_key_template,
 bucket_name=None,
 wildcard_match=False,
 aws_conn_id='conn_aws_s3',
 dag=dag
)

success_bucket = BashOperator(
    task_id='success_key_sensor',
    bash_command='echo "{{ yesterday_ds_nodash }}"',
    dag=dag
)

s3_to_stage = S3ToRedshiftTransfer(
            task_id='s3_to_stage',
            schema='staging',
            table='event',
            bucket_key=bucket_key_template,
            redshift_conn_id='conn_aws_redshift',
            aws_conn_id='conn_aws_s3',
            autocommit=True,
            dag=dag
            )


load_query = """
        BEGIN TRANSACTION;

        DELETE FROM public.event 
        USING staging.event 
        WHERE public.event.globaleventid = staging.event.globaleventid; 

        INSERT INTO event 
        SELECT * FROM staging.event;

        END TRANSACTION;

        TRUNCATE staging.event;
        """


load_data = PostgresOperator(
                task_id='load_data',
                sql=load_query,
                postgres_conn_id='conn_aws_redshift',
                autocommit=True,
                dag=dag
            )

complete_etl = DummyOperator(task_id='complete_etl', dag=dag)


file_sensor >> success_bucket >> s3_to_stage >> load_data >> complete_etl

# STAGING
# CREATE TABLE LIKE EVENT 
# https://docs.aws.amazon.com/redshift/latest/dg/merge-replacing-existing-rows.html
