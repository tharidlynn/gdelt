# terraform apply/destroy -target aws_instance.docker -target aws_security_group.docker -auto-approve

resource "aws_instance" "docker" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.docker.id}"]
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = true

  iam_instance_profile = "${var.iam_instance_profile}"

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo apt update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt install docker-ce -y",
      "sudo usermod -aG docker ubuntu",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sleep 10",
      "sudo apt install -y python3-pip python3-dev",
      "cd /usr/local/bin && sudo ln -s /usr/bin/python3 python",
      "sudo pip3 install awscli --upgrade --ignore-installed six"
    ]

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  tags = {
    Name = "docker"
  }
}


resource "aws_security_group" "docker" {
  name        = "docker-security-group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



