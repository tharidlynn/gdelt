# terraform apply/destroy -target aws_eip.airflow -target aws_instance.airflow -target aws_db_instance.airflow -target aws_security_group.airflow -target aws_security_group.airflow_db -target aws_security_group_rule.airflow_db -target aws_db_subnet_group.airflow_subnetgroup -auto-approve

data "template_file" "airflow_setup" {
  template = "${file("${path.module}/configs/setup_airflow.sh.tpl")}"
}

data "template_file" "airflow_config" {
  template = "${file("${path.module}/configs/airflow.cfg.tpl")}"
  vars = {
    fernet_key = "B25123_-Fp-hmbJdtEVMNQ2L6rBLpvF-deUhH1Wt5lc="
    db_url     = "${aws_db_instance.airflow.address}"
    db_user    = "${aws_db_instance.airflow.username}"
    db_pass    = "${aws_db_instance.airflow.password}"
  }
}

resource "aws_eip" "airflow" {
  count = "1"
  vpc = true
  instance = "${aws_instance.airflow.id}"

  tags = {
    Name = "airflow"
  }

}

resource "aws_instance" "airflow" {
  key_name                    = "${var.ssh_key_name}"
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.airflow.id}"]
  associate_public_ip_address = true
  depends_on = ["aws_db_instance.airflow"]
  iam_instance_profile = "${var.iam_instance_profile}"
  
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "airflow"
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_config.rendered}"
    destination = "/home/ubuntu/airflow.cfg"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      port = 22
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_setup.rendered}"
    destination = "/home/ubuntu/setup_airflow.sh"

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      port = 22
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }
  provisioner "file" {
    source      = "${path.module}/configs/requirements.txt"
    destination = "/home/ubuntu/requirements.txt"

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
      "bash /home/ubuntu/setup_airflow.sh"
    ]

    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "ubuntu"
      private_key = "${file(var.ssh_key_path)}"
    }
  }

  
}
resource "aws_db_instance" "airflow" {
  identifier                = "airflow-database"
  allocated_storage         = "${var.allocated_storage}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.db_name}"
  username                  = "${var.db_username}"
  password                  = "${var.db_password}"
  storage_type              = "gp2"
  backup_retention_period   = 0
  multi_az                  = false
  publicly_accessible       = false
  apply_immediately         = true
  db_subnet_group_name      = "${aws_db_subnet_group.airflow_subnetgroup.name}"
  final_snapshot_identifier = "airflow-database-final-snapshot-1"
  skip_final_snapshot       = true
  vpc_security_group_ids    = ["${aws_security_group.airflow_db.id}"]
  port                      = "5432"
}

resource "aws_security_group" "airflow" {
  name   = "airflow-security-group"
  vpc_id = "${var.vpc_id}"
  
  ingress {
    protocol = "tcp"
    from_port  = 8080
    to_port   = 8080
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation
  }

  ingress {
    protocol = "tcp"
    from_port  = 22 
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"] # <= Change to your workstation
  }

  egress {
    protocol = -1
    from_port   = 0 
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "airflow"
  }

}

resource "aws_security_group" "airflow_db" {
  name        = "allow_airflow_database"
  vpc_id = "${var.vpc_id}"
  
  ingress {
    protocol        = "tcp"
    from_port       = "5432"
    to_port         = "5432"
    security_groups = ["${aws_security_group.airflow.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "airflow_database"
  }
}


resource "aws_db_subnet_group" "airflow_subnetgroup" {
  name        = "airflow-database-subnetgroup"
  subnet_ids  = "${var.db_subnets}"
}