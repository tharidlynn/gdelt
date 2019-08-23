package twitter

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._
import com.databricks.spark.corenlp.functions._
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.DataFrameReader

object TwitterConsumer {
    def main(args: Array[String]) {

      if (args.length < 4) {
        System.exit(-1)
      }

        val kafkaHost = args(0)
        val postgresHost = args(1)
        val esHost = args(2)
        val parquetLocation = args(3)

        val spark = SparkSession.builder
                                .appName("Twitter consumer")
                                // .master("local[*]")
                                .getOrCreate()

        spark.sparkContext.setLogLevel("WARN")

        import spark.implicits._

        val twitterSchema = StructType(Seq(
                        StructField("createdAt", TimestampType, true),
                        StructField("id", LongType, true),
                        StructField("message", StringType, true),
                        StructField("source", StringType, true),
                        StructField("isTruncated", BooleanType, true),
                        StructField("userId", LongType, true),
                        StructField("username", StringType, true),
                        StructField("userScreenName", StringType, true),
                        StructField("userDesc", StringType, true),
                        StructField("userCreatedAt", TimestampType, true),
                        StructField("place", StringType, true),
                        StructField("retweetCount", IntegerType, true),
                        StructField("favCount", IntegerType, true),
                        StructField("isSensitive", BooleanType, true),
                        StructField("isRetweet", BooleanType, true),
                        StructField("retweetedStatus", StringType, true),
                        StructField("hashtags", ArrayType(StringType, true), true),
                        StructField("mentions", ArrayType(StringType, true), true)
                      ))

        val twitterSenSchema = StructType(Seq(
          StructField("createdAt", TimestampType, true),
          StructField("id", LongType, true),
          StructField("message", StringType, true),
          StructField("source", StringType, true),
          StructField("isTruncated", BooleanType, true),
          StructField("userId", LongType, true),
          StructField("username", StringType, true),
          StructField("userScreenName", StringType, true),
          StructField("userDesc", StringType, true),
          StructField("userCreatedAt", TimestampType, true),
          StructField("place", StringType, true),
          StructField("retweetCount", IntegerType, true),
          StructField("favCount", IntegerType, true),
          StructField("isSensitive", BooleanType, true),
          StructField("isRetweet", BooleanType, true),
          StructField("retweetedStatus", StringType, true),
          StructField("hashtags", ArrayType(StringType, true), true),
          StructField("mentions", ArrayType(StringType, true), true),
          StructField("messageSen", StringType, true),
          StructField("sentiment", IntegerType, true)
        )) 
          
            // val kafkaDF = rawDF
        //         .withColumn("key", $"key".cast(StringType))
        //         .withColumn("topic", $"topic".cast(StringType))
        //         .withColumn("offset", $"offset".cast(LongType))
        //         .withColumn("partition", $"partition".cast(IntegerType))
        //         .withColumn("timestamp", $"timestamp".cast(TimestampType))
        //         .withColumn("value", $"value".cast(StringType))
        //         .select("key", "value", "timestamp")


        val rawDF   = spark
                      .readStream
                      .format("kafka")
                      .option("kafka.bootstrap.servers", kafkaHost)
                      .option("subscribe", "twitter")
                      .option("startingOffsets", "latest")
                      .option("failOnDataLoss", false)
                      .load()
                      .selectExpr("CAST(value AS STRING) as json")
                      .select( from_json($"json", schema=twitterSchema).as("data"))
                      .select("data.*")
                      .withColumn("messageSen", when($"retweetedStatus".isNull, $"message").otherwise($"retweetedStatus"))
                      .withColumn("sentiment", sentiment($"messageSen"))
                      .selectExpr("CAST(id AS STRING) AS key", "to_json(struct(*)) AS value")
                      .writeStream
                      .format("kafka")
                      .option("kafka.bootstrap.servers", kafkaHost)
                      .option("checkpointLocation", "s3://gdelt-tharidspark-checkpoints/kafka-checkpoints")
                      .option("topic", "twitter-sen")
                      .start()
              
        val twitterSen = spark
                        .readStream
                        .format("kafka")
                        .option("kafka.bootstrap.servers", kafkaHost)
                        .option("subscribe", "twitter-sen")
                        .option("startingOffsets", "latest")
                        .option("failOnDataLoss", false)
                        .load()
                        .selectExpr("CAST(value AS STRING) as json")
                        .select( from_json($"json", schema=twitterSenSchema).as("data"))
                        .select("data.*")

        val twitterCountSentiment = twitterSen
                                    .withWatermark("createdAt", "10 minutes")
                                    .groupBy(
                                      window($"createdAt", "10 minutes", "5 minutes"), $"sentiment"
                                    )
                                    .count()
                                    .withColumn("window", $"window".cast(StringType))
                                    .withColumn("processing_timestamp", current_timestamp)
                                    .writeStream
                                    .outputMode("complete")
                                    .option("checkpointLocation", "s3://gdelt-tharid/spark-checkpoints/postgres-checkpoints/twiiter-count-sentiment")
                                    .trigger(Trigger.ProcessingTime("20 seconds"))
                                    .option("truncate", false)
                                    .foreachBatch { (batchDF, batchId) =>
                                        batchDF.write
                                                .mode("append")
                                                .format("jdbc")
                                                .option("url", s"jdbc:postgresql://${postgresHost}/spark")
                                                .option("dbtable", "public.count")
                                                .option("user", "john")
                                                .option("password", "")
                                                .save()
                                                  }
                                    .start()

        val twitterCountHashtags = twitterSen
                                  .withColumn("hashtag", explode($"hashtags"))
                                  .withWatermark("createdAt", "10 minutes")
                                  .groupBy(
                                    window($"createdAt", "5 minutes"), $"hashtag")
                                  .agg(count($"id").as("total"), mean("sentiment"), min("sentiment"), max("sentiment")).sort($"total".desc).limit((20))
                                  .withColumn("window", $"window".cast(StringType))
                                  .withColumn("processing_timestamp", current_timestamp)
                                  .writeStream
                                  .outputMode("complete")
                                  .option("truncate", false)
                                  .option("checkpointLocation", "s3://gdelt-tharid/spark-checkpoints/postgres-checkpoints/twitter-count-hashtag")
                                  .trigger(Trigger.ProcessingTime("20 seconds"))
                                  .foreachBatch { (batchDF, batchId) =>
                                    batchDF.write
                                            .mode("append")
                                            .format("jdbc")
                                            .option("url", s"jdbc:postgresql://${postgresHost}/spark")
                                            .option("dbtable", "public.count_hashtags")
                                            .option("user", "john")
                                            .option("password", "")
                                            .save()
                                  }
                                  .start()

           val esQuery = twitterSen.writeStream
                      .format("org.elasticsearch.spark.sql")
                      .option("checkpointLocation", "s3://gdelt-tharid/spark-checkpoints/es-checkpoints/")
                      .option("es.nodes", esHost)
                      .option("es.port", "9200")
                      .option("es.index.auto.create", "true") 
                      .trigger(Trigger.ProcessingTime("20 seconds"))
                    //   .option("es.net.http.auth.user", "username")
                    //   .option("es.net.http.auth.pass", "pasword")
                      .outputMode("append")
                      .start("twitter/tweet")
          

          val parquetWrite = twitterSen.writeStream
                            .format("parquet")
                            .option("checkpointLocation", "s3://gdelt-tharid/spark-checkpoints/parquet-checkpoints")
                            .option("path", parquetLocation)
                            .trigger(Trigger.ProcessingTime("20 seconds"))
                            .start()

          spark.streams.awaitAnyTermination()

    }
  }
