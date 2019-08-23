# terraform apply/destroy -target aws_instance.es -target aws_security_group.es -auto-approve

resource "aws_instance" "es" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.es.id}"]
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = false


    provisioner "remote-exec" {
        inline = [
            "sleep 20",
            "sudo apt-get update",
            "sudo apt install openjdk-8-jre-headless -y",
            "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
            "echo 'deb https://artifacts.elastic.co/packages/6.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list",
            "sudo apt update",
            "sudo apt install elasticsearch",
            "sudo bash -c \"echo 'network.host: ${self.private_ip}' >> /etc/elasticsearch/elasticsearch.yml\"",
            "sudo systemctl start elasticsearch",
            "sudo systemctl enable elasticsearch",
        ]
        connection {
            type = "ssh"
            host = "${self.private_ip}"
            user = "ubuntu"
            private_key = "${file(var.ssh_key_path)}"

            bastion_host = "${var.bastion_public_ip}"
            bastion_user = "ubuntu"
            bastion_private_key = "${file(var.ssh_key_path)}"
        }       
    }

  tags = {
    Name = "elastic_search"
  }

}

resource "aws_security_group" "es" {
  name        = "elastic_search"
  vpc_id = "${var.vpc_id}"
  
  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation

  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  egress {
    protocol = -1
    from_port   = 0 
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "elasticsearch"
  }
}

