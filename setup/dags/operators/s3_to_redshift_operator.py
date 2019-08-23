# -*- coding: utf-8 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

from airflow.hooks.postgres_hook import PostgresHook
from airflow.hooks.S3_hook import S3Hook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class S3ToRedshiftTransfer(BaseOperator):
    
    template_fields = ('bucket_key',)
    template_ext = ()
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            schema,
            table,
            bucket_key,
            redshift_conn_id='redshift_default',
            aws_conn_id='aws_default',
            verify=None,
            autocommit=False,
            *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.schema = schema
        self.table = table
        self.bucket_key = bucket_key
        self.redshift_conn_id = redshift_conn_id
        self.aws_conn_id = aws_conn_id
        self.verify = verify
        self.autocommit = autocommit


    def execute(self, context):
        self.hook = PostgresHook(postgres_conn_id=self.redshift_conn_id)
        self.s3 = S3Hook(aws_conn_id=self.aws_conn_id, verify=self.verify)
        credentials = self.s3.get_credentials()
        
        copy_query = """
            COPY {schema}.{table}
            FROM '{bucket_key}'
            with credentials
            'aws_access_key_id={access_key};aws_secret_access_key={secret_key}'
            REGION 'us-east-1' DELIMITER '\t' FILLRECORD;
        """.format(schema=self.schema,
                   table=self.table,
                   bucket_key=self.bucket_key,
                   access_key=credentials.access_key,
                   secret_key=credentials.secret_key
                   )

        self.log.info('Executing COPY command...')
        self.hook.run(copy_query, self.autocommit)
        self.log.info("COPY command complete...")
