# terraform apply/destroy -target aws_eip.bastion -target aws_instance.bastion -target aws_security_group.bastion -auto-approve
resource "aws_eip" "bastion" {
  count = "1"
  vpc = true
  instance = "${aws_instance.bastion.id}"
}

resource "aws_instance" "bastion" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "allow_ssh_for_bastion"
  vpc_id      = "${var.vpc_id}"
  
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
    Name = "bastion"
  }
}

