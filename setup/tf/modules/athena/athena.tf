
# terraform apply/destroy -target aws_athena_database.gdelt -target aws_s3_bucket.gdelt-athena-outputs -auto-approve

resource "aws_athena_database" "gdelt" {
  name   = "${var.athena_db_name}"
  bucket = "${aws_s3_bucket.gdelt-athena-outputs.bucket}"
}

# output athena results bucket
resource "aws_s3_bucket" "gdelt-athena-outputs" {
  bucket = "${var.athena_bucket_name}"

  tags = {
    Name        = "${var.athena_bucket_name}"
  }
}
