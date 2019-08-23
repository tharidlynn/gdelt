import Dependencies._

ThisBuild / scalaVersion     := "2.11.12"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "com.example"
ThisBuild / organizationName := "example Company"

resolvers += "SparkPackages" at "https://dl.bintray.com/spark-packages/maven"

lazy val root = (project in file("."))
  .settings(
    name := "sparkConsumer",
    libraryDependencies += scalaTest % Test,
    libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.4.3" % "provided", 
    libraryDependencies += "org.apache.spark" %% "spark-sql-kafka-0-10" % "2.4.3" % "provided",
    libraryDependencies += "databricks" % "spark-corenlp" % "0.4.0-spark2.4-scala2.11",
    libraryDependencies += "org.elasticsearch" % "elasticsearch-hadoop" % "6.4.2",
    libraryDependencies += "org.postgresql" % "postgresql" % "42.2.6"
  )