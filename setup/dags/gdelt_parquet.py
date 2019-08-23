from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.sensors.s3_key_sensor import S3KeySensor
from airflow.contrib.operators.emr_create_job_flow_operator import EmrCreateJobFlowOperator
from airflow.contrib.operators.emr_add_steps_operator import EmrAddStepsOperator
from airflow.contrib.operators.emr_terminate_job_flow_operator import EmrTerminateJobFlowOperator
from airflow.contrib.sensors.emr_step_sensor import EmrStepSensor

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
 
dag = DAG(dag_id='gdelt_emr',
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
    dag=dag,
    bash_command='echo "{{ yesterday_ds_nodash }}"'
)

create_emr = EmrCreateJobFlowOperator(task_id='create_emr',
                                      dag=dag,
                                      aws_conn_id='conn_aws_id',
                                      emr_conn_id='conn_aws_emr',
                                      job_flow_overrides=''
                                     )


json_step = [
                {
                    'Name': 'Spark Parquet',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': 'command-runner.jar',
                        'Args': [
                            'spark-submit', '--deploy-mode', 'cluster', '--class', 'com.example.SparkParquet', 's3://gdelt-tharid/sparkparquet_2.12-0.3.jar', '{{ yesterday_ds_nodash }}'
                        ]
                    }
                }
            ]
                
add_step_emr = EmrAddStepsOperator(
        task_id='add_step_emr',
        dag=dag,
        job_flow_id='{{ task_instance.xcom_pull("create_emr", key="return_value") }}',
        aws_conn_id='conn_aws_id',
        steps=json_step
    )

check_step_emr = EmrStepSensor(task_id='watch_step_emr',
                               dag=dag,
                               job_flow_id='{{ task_instance.xcom_pull("create_emr", key="return_value") }}',
                               step_id='{{ task_instance.xcom_pull("add_step_emr", key="return_value")[0] }}',
                               aws_conn_id='conn_aws_id',
                                )

terminate_emr = EmrTerminateJobFlowOperator(task_id='terminate_emr',
                                            dag=dag,
                                            job_flow_id='{{ task_instance.xcom_pull("create_emr", key="return_value") }}',
                                            aws_conn_id='conn_aws_id'
                                            )

complete_emr = DummyOperator(task_id='complete_emr', dag=dag)

file_sensor >> success_bucket >> create_emr >> add_step_emr >> check_step_emr >> terminate_emr >> complete_emr