resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ec2_profile_name}"
  role = "${aws_iam_role.ec2_s3_kafka_access_role.name}"
}

resource "aws_iam_role" "ec2_s3_kafka_access_role" {
  name               = "${var.role_name}"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": "sts:AssumeRole",
"Principal": {
"Service": "ec2.amazonaws.com"
},
"Effect": "Allow",
"Sid": ""
}
]
}
EOF
}

resource "aws_iam_role_policy" "ec2_s3_kafka_policy" {
  name = "${var.policy_name}"
  role = "${aws_iam_role.ec2_s3_kafka_access_role.id}"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": [
"s3:*"
],
"Effect": "Allow",
"Resource": "*"
},
{
"Effect": "Allow",
"Action": [
"kafka:*",
"ec2:DescribeSubnets",
"ec2:DescribeVpcs",
"ec2:DescribeSecurityGroups",
"kms:DescribeKey",
"kms:CreateGrant"
],
"Resource": "*"
},
{
"Effect": "Allow",
"Action": "iam:CreateServiceLinkedRole",
"Resource": "arn:aws:iam::*:role/aws-service-role/kafka.amazonaws.com/AWSServiceRoleForKafka*",
"Condition": {
"StringLike": {
  "iam:AWSServiceName": "kafka.amazonaws.com"
}
}
},
{
"Effect": "Allow",
"Action": [
"iam:AttachRolePolicy",
"iam:PutRolePolicy"
],
"Resource": "arn:aws:iam::*:role/aws-service-role/kafka.amazonaws.com/AWSServiceRoleForKafka*"
}
]
}
EOF
}