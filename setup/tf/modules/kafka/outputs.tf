output "bootstrap_brokers" {
  value       = "${aws_msk_cluster.kafka.bootstrap_brokers}"
}

output "zookeeper_connect_string" {
  value = "${aws_msk_cluster.kafka.zookeeper_connect_string}"
}
