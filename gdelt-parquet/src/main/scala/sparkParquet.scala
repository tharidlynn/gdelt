package com.example

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.Dataset
import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._

object SparkParquet {

  def main(args: Array[String]) {

    val spark = SparkSession
                .builder()
                .appName("CsvtoParquet")
                // .config("spark.some.config.option", "some-value")
                .getOrCreate()

    import spark.implicits._

    val sourcePath: String = if (args.length > 0) s"s3://gdelt-open-data/events/${args(0)}.export.csv" else "s3://gdelt-open-data/events/*.csv"
    
    val customSchema = StructType(Seq(
                        StructField("globaleventid", IntegerType, true),  
                        StructField("day", StringType, true),
                        StructField("monthyear", IntegerType, true),
                        StructField("year", IntegerType, true),
                        StructField("fractiondate", DoubleType, true),
                        StructField("actor1code", StringType, true),
                        StructField("actor1name", StringType, true),
                        StructField("actor1countrycode", StringType, true),
                        StructField("actor1knowngroupcode", StringType, true),
                        StructField("actor1ethniccode", StringType, true),
                        StructField("actor1religion1code", StringType, true),
                        StructField("actor1religion2code", StringType, true),
                        StructField("actor1type1code", StringType, true),
                        StructField("actor1type2code", StringType, true),
                        StructField("actor1type3code", StringType, true),
                        StructField("actor2code", StringType, true),
                        StructField("actor2name", StringType, true),
                        StructField("actor2countrycode", StringType, true),
                        StructField("actor2knowngroupcode", StringType, true),
                        StructField("actor2ethniccode", StringType, true),
                        StructField("actor2religion1code", StringType, true),
                        StructField("actor2religion2code", StringType, true),
                        StructField("actor2type1code", StringType, true),
                        StructField("actor2type2code", StringType, true),
                        StructField("actor2type3code", StringType, true),
                        StructField("isrootevent", IntegerType, true),
                        StructField("eventcode", IntegerType, true),
                        StructField("eventbasecode", IntegerType, true),
                        StructField("eventrootcode", IntegerType, true),
                        StructField("quadclass", IntegerType, true),
                        StructField("goldsteinscale", DoubleType, true),
                        StructField("nummentions", IntegerType, true),
                        StructField("numsources", IntegerType, true),
                        StructField("numarticles", IntegerType, true),
                        StructField("avgtone", DoubleType, true),
                        StructField("actor1geo_type", IntegerType, true),
                        StructField("actor1geo_fullname", StringType, true),
                        StructField("actor1geo_countrycode", StringType, true),
                        StructField("actor1geo_adm1code", StringType, true),
                        StructField("actor1geo_lat", DoubleType, true),
                        StructField("actor1geo_long", DoubleType, true),
                        StructField("actor1geo_featureid", StringType, true),
                        StructField("actor2geo_type", IntegerType, true),
                        StructField("actor2geo_fullname", StringType, true),
                        StructField("actor2geo_countrycode", StringType, true),
                        StructField("actor2geo_adm1code", StringType, true),
                        StructField("actor2geo_lat", DoubleType, true),
                        StructField("actor2geo_long", DoubleType, true),
                        StructField("actor2geo_featureid", StringType, true),
                        StructField("actiongeo_type", IntegerType, true),
                        StructField("actiongeo_fullname", StringType, true),
                        StructField("actiongeo_countrycode", StringType, true),
                        StructField("actiongeo_adm1code", StringType, true),
                        StructField("actiongeo_lat", DoubleType, true),
                        StructField("actiongeo_long", DoubleType, true),
                        StructField("actiongeo_featureid", StringType, true),
                        StructField("dateadded", StringType, true),
                        StructField("sourceurl", StringType, true)
                      ))    
    

    val ds = spark
            .read
            .option("sep","\t")
            .option("header","false")
            .option("inferSchema", "false")
            .schema(customSchema)
            .csv(sourcePath)
    
    val ds_final = ds.withColumn("date_day", dayofmonth(to_date($"day", "yyyyMMdd")))
                     .withColumn("date_month", month(to_date($"day", "yyyyMMdd")))
    
    ds_final.repartition($"year")
            .write.mode("append")
            .partitionBy("year", "date_month", "date_day")
            .parquet("s3://gdelt-tharid/parquet-event")
            
    spark.stop()
  }
}

