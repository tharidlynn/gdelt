resource "aws_db_instance" "yahoo_db_replica" {
  identifier                = "${var.identifier}"
  replicate_source_db       = "${var.replicate_source_db}"
  allocated_storage         = "${var.allocated_storage}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.instance_class}"
  name                      = "${var.name}"
  storage_type              = "gp2"
  multi_az                  = "${var.multi_az}"
  publicly_accessible       = "${var.publicly_accessible}"
  apply_immediately         = "${var.apply_immediately}"
  final_snapshot_identifier = "${var.final_snapshot_identifier}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  vpc_security_group_ids    = ["${aws_security_group.yahoo_db_replica.id}"]
  port                      = "${var.port}"

  tags = {
    Name       = "yahoo-db-replica"
  }

}
resource "aws_security_group" "yahoo_db_replica" {
  name   = "yahoo-replica-security-group"
  vpc_id  = "${var.vpc_id}"
  
  ingress {
    protocol = "tcp"
    from_port  = 5432
    to_port   = 5432
    security_groups = ["${var.bastion_security_group_id}"]
  }

  egress {
    protocol = -1
    from_port   = 0 
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "yahoo_db_replica"
  }
}
