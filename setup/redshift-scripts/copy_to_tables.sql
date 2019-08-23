COPY event
FROM 's3://gdelt-open-data/events/'
CREDENTIALS 'aws_access_key_id=xxxxxxxx;aws_secret_access_key=xxxxxxxxxxxxx'
-- IAM_ROLE 'arn:aws:iam::111111111111:role/RedshiftS3ReadAccessRole'
REGION 'us-east-1'  
DELIMITER '\t'
FILLRECORD
COMPUPDATE ON;

-- check column encoding
SELECT "column", type, encoding 
FROM pg_table_def WHERE tablename = 'event';

ANALYZE COMPRESSION event;

COPY eventcode
FROM 's3://gdelt-tharid/eventcode.txt/'
CREDENTIALS 'aws_access_key_id=xxxxxxxx;aws_secret_access_key=xxxxxxxxxxxxx'
-- IAM_ROLE 'arn:aws:iam::111111111111:role/RedshiftS3ReadAccessRole'
REGION 'ap-southeast-1'  
DELIMITER '\t';

COPY type
FROM 's3://gdelt-tharid/type.txt/'
CREDENTIALS 'aws_access_key_id=xxxxxxxx;aws_secret_access_key=xxxxxxxxxxxxx'
-- IAM_ROLE 'arn:aws:iam::111111111111:role/RedshiftS3ReadAccessRole'
REGION 'ap-southeast-1'  
DELIMITER '\t';

COPY "group"
FROM 's3://gdelt-tharid/group.txt/'
CREDENTIALS 'aws_access_key_id=xxxxxxxx;aws_secret_access_key=xxxxxxxxxxxxx'
-- IAM_ROLE 'arn:aws:iam::111111111111:role/RedshiftS3ReadAccessRole'
REGION 'ap-southeast-1'  
DELIMITER '\t';

COPY country
FROM 's3://gdelt-tharid/country.txt/'
CREDENTIALS 'aws_access_key_id=xxxxxxxx;aws_secret_access_key=xxxxxxxxxxxxx'
-- IAM_ROLE 'arn:aws:iam::111111111111:role/RedshiftS3ReadAccessRole'
REGION 'ap-southeast-1'  
DELIMITER '\t';

