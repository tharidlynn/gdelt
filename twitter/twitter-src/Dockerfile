FROM openjdk:8

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY target/scala-2.12/twitter-src-assembly-0.1.0-SNAPSHOT.jar ./

ENV OAuthConsumerKey=""
ENV OAuthConsumerSecret=""
ENV OAuthAccessToken=""
ENV OAuthAccessTokenSecret=""

#<kafka-host> <kafka-topic> <twitter-search-keywords *>
ENTRYPOINT ["java", "-jar", "twitter-src-assembly-0.1.0-SNAPSHOT.jar"]