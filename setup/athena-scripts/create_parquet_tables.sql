-- for Athena only 

DROP TABLE IF EXISTS gdelt.eventparquet;

CREATE EXTERNAL TABLE IF NOT EXISTS gdelt.eventparquet (
	`globaleventid` INT,
	`day` INT,
	`monthyear` INT,
	`fractiondate` DOUBLE,
	`actor1code` string,
	`actor1name` string,
	`actor1countrycode` string,
	`actor1knowngroupcode` string,
	`actor1ethniccode` string,
	`actor1religion1code` string,
	`actor1religion2code` string,
	`actor1type1code` string,
	`actor1type2code` string,
	`actor1type3code` string,
	`actor2code` string,
	`actor2name` string,
	`actor2countrycode` string,
	`actor2knowngroupcode` string,
	`actor2ethniccode` string,
	`actor2religion1code` string,
	`actor2religion2code` string,
	`actor2type1code` string,
	`actor2type2code` string,
	`actor2type3code` string,
	`isrootevent` INT,
	`eventcode` INT,
	`eventbasecode` INT,
	`eventrootcode` INT,
	`quadclass` INT,
	`goldsteinscale` DOUBLE,
	`nummentions` INT,
	`numsources` INT,
	`numarticles` INT,
	`avgtone` DOUBLE,
	`actor1geo_type` INT,
	`actor1geo_fullname` string,
	`actor1geo_countrycode` string,
	`actor1geo_adm1code` string,
	`actor1geo_lat` DOUBLE,
	`actor1geo_long` DOUBLE,
	`actor1geo_featureid` string,
	`actor2geo_type` INT,
	`actor2geo_fullname` string,
	`actor2geo_countrycode` string,
	`actor2geo_adm1code` string,
	`actor2geo_lat` DOUBLE,
	`actor2geo_long` DOUBLE,
	`actor2geo_featureid` string,
	`actiongeo_type` INT,
	`actiongeo_fullname` string,
	`actiongeo_countrycode` string,
	`actiongeo_adm1code` string,
	`actiongeo_lat` DOUBLE,
	`actiongeo_long` DOUBLE,
	`actiongeo_featureid` string,
	`dateadded` string,
	`sourceurl` string
) PARTITIONED BY
	(
	year int,
	date_month int,
	date_day int) STORED AS PARQUET LOCATION 's3://gdelt-tharid/event-parquet' tblproperties (
"parquet.compress" = "SNAPPY"
);

-- To allow the catalog to recognize all partitions,
-- run after the query is complete and you can list all your partitions.

MSCK REPAIR TABLE gdelt.eventsparquet;

SHOW PARTITIONS gdelt.eventsparquet;