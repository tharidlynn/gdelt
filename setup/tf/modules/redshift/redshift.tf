module "redshift" {
  source  = "terraform-aws-modules/redshift/aws"
  version = "~> 2.0"

  cluster_identifier      = "${var.cluster_identifier}"
  cluster_node_type       = "${var.cluster_node_type}"
  cluster_number_of_nodes = "${var.cluster_number_of_nodes}"

  cluster_database_name   = "${var.cluster_database_name}"
  cluster_master_username = "${var.cluster_master_username}"
  cluster_master_password = "${var.cluster_master_password}"
  
  vpc_security_group_ids = ["${aws_security_group.redshift.id}"]
  subnets                = "${var.subnets}"
  cluster_iam_roles      =  "${var.cluster_iam_roles}"
 
}
resource "aws_security_group" "redshift" {
    name   = "redshift_security_group"
    vpc_id  = "${var.vpc_id}"

    ingress {
        protocol = "tcp"
        from_port  = 5439
        to_port   = 5439
        security_groups = ["${var.bastion_security_group_id}"]
    }

    ingress {
        protocol = "tcp"
        from_port  = 5439
        to_port   = 5439
        security_groups = ["${var.airflow_security_group_id}"]
    }
    
    egress {
        protocol = -1
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

}