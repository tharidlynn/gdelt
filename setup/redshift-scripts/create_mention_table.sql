CREATE EXTERNAL SCHEMA spectrum
FROM data catalog
DATABASE 'gdelt'
IAM_ROLE 'arn:aws:iam::11111111:role/RedshiftS3ReadAccessRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

CREATE EXTERNAL TABLE spectrum.mention (
    globaleventid INT,
    eventtimedate INT,
    mentiontimedate INT,
    mentiontype INT,
    mentionsourcename INT,
    mentionidentifier INT,
    sentenceid INT,
    actor1charoffset INT,
    actor2charoffset INT,
    actioncharoffset INT,
    inrawtext INT,
    confidence INT,
    mentiondoclen INT,
    mentiondoctone INT,
    mentiondoctranslationinfo TEXT,
    extras TEXT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS textfile
LOCATION 's3://gdelt-tharid/mention/'
TABLE PROPERTIES ('compression_type'='gzip');