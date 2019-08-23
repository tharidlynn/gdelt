provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "data-eng-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  # enable dns for emr
  enable_dns_hostnames = true
  create_redshift_subnet_group = false

  public_subnet_tags = {
    Name = "data-eng-pub"
  }

  private_subnet_tags = {
    Name = "data-eng-priv"
  }

 
  tags = {
    Owner       = "tharid007"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "data-eng-vpc"
  }
}

# create s3_access_role
module "ec2_profile" {
    source = "./modules/ec2-profile"
    ec2_profile_name = "ec2_profile"
    role_name = "Tharid_EC2S3KafkaAccessRole"
    policy_name = "Tharid_EC2S3KafkaPolicy"

}

module "airflow" {
    source = "./modules/airflow"   
    ami = "${var.ami}"
    instance_type = "t2.medium"
    ssh_key_name = "test_key"
    ssh_key_path = "~/test_key.pem"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.public_subnets[0]}"
    iam_instance_profile = "${module.ec2_profile.name}"

    engine  = "postgres"
    engine_version = "10.6"
    instance_class = "db.t2.small"
    allocated_storage = "20"
    db_name = "airflow"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_subnets = "${module.vpc.private_subnets}"

}

module "athena" {
    source = "./modules/athena"
    athena_db_name = "gdelt"
    athena_bucket_name = "gdelt-athena-outputs"
}

module "bastion" {
    source = "./modules/bastion"
    ami = "${var.ami}"
    instance_type = "t2.nano"
    ssh_key_name = "test_key"

    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.public_subnets[0]}"

}

module "docker" {
    source = "./modules/docker"
    ami = "${var.ami}"
    instance_type = "t2.nano"
    ssh_key_name = "test_key"
    ssh_key_path = "~/test_key.pem"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.public_subnets[0]}"

    iam_instance_profile = "${module.ec2_profile.name}"
}

# depends on bastion
module "elasticsearch" {
    source = "./modules/elasticsearch"
    ami = "${var.ami}"
    instance_type = "t2.medium"
    ssh_key_name = "test_key"
    ssh_key_path = "~/test_key.pem"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.private_subnets[0]}"

    bastion_public_ip = "${module.bastion.public_ip}"
    bastion_security_group_id = "${module.bastion.security_group_id}"
}

module "emr" {
    source = "./modules/emr"
    release_label = "emr-5.24.0"
    log_uri = "s3://gdelt-tharid/emr-logs"
    master_instance_type = "m4.large"
    core_instance_type = "m5.2xlarge"
    core_instance_count = 5
    ssh_key_name = "test_key"
    vpc_id = "${module.vpc.vpc_id}"
    subnet_id = "${module.vpc.public_subnets[0]}"

}

module "kafka" {
    source = "./modules/kafka"
    cluster_name = "kafka-cluster"
    number_of_broker_nodes = 3
    instance_type = "kafka.m5.large"
    kafka_version = "2.2.1"
    ebs_volume_size = "10"
    client_subnets = "${module.vpc.public_subnets}"
    aws_msk_configuration_name = "kafka-configuration99"
    encrpytion_client_broker = "PLAINTEXT"

    vpc_id = "${module.vpc.vpc_id}"
}

# depends on kafka 
module "kafka_connect" {
  source = "./modules/kafka-connect"
  kafka_host = "${module.kafka.bootstrap_brokers}"

  ami = "${var.ami}"
  instance_type = "t2.nano"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  ssh_key_name = "test_key"
  ssh_key_path ="~/test_key.pem"
  iam_instance_profile = "${module.ec2_profile.name}"
}

module "redshift" {
  source = "./modules/redshift"
  cluster_identifier      = "gdelt-redshift-cluster"
  cluster_node_type       = "dc2.large"
  cluster_number_of_nodes = 2  
  cluster_database_name   = "gdelt"
  cluster_master_username = "${var.db_username}"
  cluster_master_password = "${var.db_password}"
  cluster_iam_roles = ["arn:aws:iam::123523539192:role/RedshiftS3ReadAccessRole"]

  subnets                   =  "${module.vpc.private_subnets}"
  vpc_id                    =  "${module.vpc.vpc_id}"
  bastion_security_group_id =  "${module.bastion.security_group_id}"
  airflow_security_group_id =  "${module.airflow.security_group_id}"
}

# depends on bastion and emr
module "spark_db" {
  source = "./modules/spark-db"

  identifier = "spark-database"
  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t2.small"
  allocated_storage = 5

  name = "spark"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = "5432"

  multi_az                  = false
  publicly_accessible       = false
  apply_immediately         = true

  final_snapshot_identifier = "spark-database-final-snapshot-1"
  skip_final_snapshot       = true

  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  bastion_security_group_id = "${module.bastion.security_group_id}"
  emr_security_group_id     = "${module.emr.security_group_id}"
}

# depends on bastion and docker
module "yahoo_db" {
  source = "./modules/yahoo-db"

  identifier = "yahoo-database"
  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t2.small"
  allocated_storage = 5

  name = "yahoo"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = "5432"
  

  multi_az                  = false
  publicly_accessible       = false
  apply_immediately         = true

  final_snapshot_identifier = "yahoo-database-final-snapshot-1"
  skip_final_snapshot       = true

  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  bastion_security_group_id = "${module.bastion.security_group_id}"
  docker_security_group_id     = "${module.docker.security_group_id}"
}

# depens on yahoo_db
module "yahoo_db_replica" {
  source = "./modules/yahoo-db-replica"

  identifier = "yahoo-database-replica"
  replicate_source_db = "${module.yahoo_db.id}"
  engine            = "postgres"
  engine_version    = "10.6"
  instance_class    = "db.t2.small"
  allocated_storage = 5

  name = "yahoo"
  port     = "5432"

  multi_az                  = false
  publicly_accessible       = false
  apply_immediately         = true

  final_snapshot_identifier = "yahoo-replica-final-snapshot-1"
  skip_final_snapshot       = true

  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  bastion_security_group_id = "${module.bastion.security_group_id}"
}

