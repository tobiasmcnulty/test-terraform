resource "aws_s3_bucket" "s3" {
    bucket = "${var.project_name}"
    acl = "private"  # FIXME - security groups etc.

    tags {
        Name = "${var.project_name} S3"
        deployment = "${var.deployment}"
        environment = "${var.environment}"
        role = "s3"
    }
}
