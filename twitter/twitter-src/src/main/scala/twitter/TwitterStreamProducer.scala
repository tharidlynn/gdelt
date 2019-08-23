package twitter

import twitter4j._
import java.sql.Timestamp

import org.json4s._
import org.json4s.JsonDSL._
import org.json4s.jackson.Serialization
import org.json4s.jackson.Serialization.write

import java.util.Properties
import org.apache.kafka.clients.producer.Producer
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}


case class Tweet(createdAt: Timestamp, id: Long, message: String, source: String, isTruncated: Boolean, 
                 userId: Long, username: String, userScreenName: String, userDesc: String, userCreatedAt: Timestamp, 
                 place: String, retweetCount: Int, favCount: Int, isSensitive: Boolean, isRetweet: Boolean,
                 retweetedStatus: String, hashtags: Array[String], mentions: Array[String])


object TwitterStreamProducer {

  def getTwitterInstance: TwitterStream = {
    val cb = new conf.ConfigurationBuilder()
      cb.setDebugEnabled(true)
        .setOAuthConsumerKey(sys.env.get("OAuthConsumerKey").getOrElse("x"))
        .setOAuthConsumerSecret(sys.env.get("OAuthConsumerSecret").getOrElse("x"))
        .setOAuthAccessToken(sys.env.get("OAuthAccessToken").getOrElse("x"))
        .setOAuthAccessTokenSecret(sys.env.get("OAuthAccessTokenSecret").getOrElse("x"))

      val twitter: TwitterStream = new TwitterStreamFactory(cb.build()).getInstance()

      return twitter
      
  }

  def twitterInstance(twitter: TwitterStream, topic: String, producer: KafkaProducer[String, String]): TwitterStream = {
    
    val twitterStream: TwitterStream = twitter.addListener(new StatusListener() {
     
      override def onStatus(status: Status): Unit = {

        implicit val formats = DefaultFormats

        val createdAt = new Timestamp(status.getCreatedAt.getTime)
        val userCreatedAt = new Timestamp(status.getUser.getCreatedAt.getTime)
        val place = if (status.getPlace == null) null else status.getPlace.getFullName
        val retweetCount = if (status.getRetweetedStatus == null) 0 else status.getRetweetedStatus.getRetweetCount
        val retweetStatus = if (status.getRetweetedStatus == null) null else status.getRetweetedStatus.getText
        val hashtags = if (status.getHashtagEntities != null) status.getHashtagEntities.map(_.getText.toLowerCase) else Array[String]()
        val mentions = if (status.getUserMentionEntities != null) status.getUserMentionEntities.map(_.getId.toString) else Array[String]()

        val tweet = Tweet(createdAt, status.getId, status.getText, status.getSource, status.isTruncated, 
                          status.getUser.getId, status.getUser.getName, status.getUser.getScreenName, status.getUser.getDescription, 
                          userCreatedAt, place, retweetCount, status.getFavoriteCount, status.isPossiblySensitive, 
                          status.isRetweet, retweetStatus, hashtags, mentions)
        
        sendEvent(producer=producer, topic, message=write(tweet))

      }
  
      override def onDeletionNotice(statusDeletionNotice: StatusDeletionNotice): Unit = {}
      override def onTrackLimitationNotice(numberOfLimitedStatuses: Int): Unit = {}
      override def onScrubGeo(userId: Long, upToStatusId: Long): Unit = {}
      override def onStallWarning(warning: StallWarning): Unit = {}
      override def onException(ex: Exception): Unit = ex.printStackTrace()


    })

    return twitterStream
  }

  def getFilter(keywords: Array[String]): FilterQuery = {
    val fq: FilterQuery = new FilterQuery() 
    fq.track(keywords: _*)
    fq.language("en")

    return fq
  }

  def sendEvent(producer: KafkaProducer[String, String], topic: String, message: String): Unit = {
    val key = java.util.UUID.randomUUID.toString
    producer.send(new ProducerRecord(topic, key, message))
  }
  

  def main(args: Array[String]): Unit = {
    
    if (args.length < 3) {
      println("Usage: <kafka-host> <kafka-topic> <twitter-search-keywords *>")
      System.exit(-1)
    }

    val kafkaBrokers = args(0)
    val kafkaTopic = args(1)
    val kafkaKeywords = args.drop(2)
    
    val configs = new Properties()

    configs.put("bootstrap.servers", kafkaBrokers)
    configs.put("acks", "all")
    configs.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    configs.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")

    val producer = new KafkaProducer[String, String](configs)

    val twitterRawStream = twitterInstance(getTwitterInstance, kafkaTopic, producer)
    twitterRawStream.filter(getFilter(kafkaKeywords))

  }
}

