resource "aws_s3_bucket" "log_bucket" {
    bucket = "${var.bucket_name}-log"
    acl = "log-delivery-write"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.bucket_name}"
    acl = "private"
    versioning {
        enabled = true
    }
    logging {
       target_bucket = "${aws_s3_bucket.log_bucket.id}"
       target_prefix = "log/"
    }
    tags {
        Name = "TerraForm State"
        role = "s3"
    }
}
