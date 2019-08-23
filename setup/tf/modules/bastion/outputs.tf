output "public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "security_group_id" {
    value = "${aws_security_group.bastion.id}"
}