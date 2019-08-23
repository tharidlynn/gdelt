# terraform apply/destroy -target aws_instance.kafka_instance -target aws_security_group.kafka_instance -auto-approve

data "template_file" "connect_standalone" {
  template = "${file("${path.module}/configs/connect-standalone.properties.tpl")}"
  vars = {
    kafka_host = "${var.kafka_host}"
  }
}

data "template_file" "s3_sink_twitter" {
  template = "${file("${path.module}/configs/s3-sink-twitter.properties.tpl")}"
}

resource "aws_instance" "kafka_instance" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.kafka_instance.id}"]
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = true
  iam_instance_profile = "${var.iam_instance_profile}"

  provisioner "file" {
    content     = "${data.template_file.connect_standalone.rendered}"
    destination = "/home/ubuntu/connect-standalone.properties"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      port = 22
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.s3_sink_twitter.rendered}"
    destination = "/home/ubuntu/s3-sink-twitter.properties"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      port = 22
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo apt update",
      "sudo apt install unzip openjdk-8-jre-headless -y",
      "wget https://archive.apache.org/dist/kafka/2.1.0/kafka_2.12-2.1.0.tgz",
      "tar -xzf kafka_2.12-2.1.0.tgz",
      "sudo apt install -y python3-pip python3-dev",
      "cd /usr/local/bin && sudo ln -s /usr/bin/python3 python",
      "sudo pip3 install awscli --upgrade --ignore-installed six",
      "sudo chown -R ubuntu:ubuntu /usr/local/share/",
      "mkdir -p /usr/local/share/kafka/plugins/"
    ]

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  tags = {
    Name = "kafka"
  }
}

resource "aws_security_group" "kafka_instance" {
  name        = "kafka-connect"
  vpc_id = "${var.vpc_id}"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation

  }

  egress {
    protocol = -1
    from_port   = 0 
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "kafka"
  }
}
