# terraform apply/destroy -target aws_msk_cluster.kafka -target aws_msk_configuration.kafka -target aws_security_group.kafka -auto-approve

resource "aws_msk_cluster" "kafka" {
  cluster_name           = "${var.cluster_name}"
  kafka_version          = "${var.kafka_version}"
  number_of_broker_nodes = "${var.number_of_broker_nodes}"

  broker_node_group_info {
    instance_type  = "${var.instance_type}"
    ebs_volume_size = "${var.ebs_volume_size}"
    client_subnets = "${var.client_subnets}"
    security_groups = ["${aws_security_group.kafka.id}"]
  }

  configuration_info {
      arn = "${aws_msk_configuration.kafka.arn}"
      revision = "${aws_msk_configuration.kafka.latest_revision}"
   }

  encryption_info {
    encryption_in_transit  {
      client_broker = "${var.encrpytion_client_broker}"
    }
  }
   tags = {
        Name = "kafka"
    }

}

resource "aws_msk_configuration" "kafka" {
  kafka_versions = ["${var.kafka_version}"]
  name           = "${var.aws_msk_configuration_name}"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_security_group" "kafka" {
    name   = "kafka_security_group"
    vpc_id  = "${var.vpc_id}"

    ingress {
        protocol = -1
        from_port  = 0
        to_port   = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = -1
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

}