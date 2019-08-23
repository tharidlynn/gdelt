import Dependencies._

ThisBuild / scalaVersion     := "2.12.8"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "twitter"
ThisBuild / organizationName := "Twitter Analysis company"

lazy val root = (project in file("."))
  .settings(
    name := "twitter-src",
    libraryDependencies += scalaTest % Test,
    libraryDependencies += "org.twitter4j" % "twitter4j-core" % "4.0.7",
    libraryDependencies += "org.twitter4j" % "twitter4j-stream" % "4.0.7",
    libraryDependencies += "org.apache.kafka" %% "kafka" % "2.2.0",
    libraryDependencies += "org.json4s" %% "json4s-native" % "3.6.5",
    libraryDependencies += "org.json4s" %% "json4s-jackson" % "3.6.5"
  )
