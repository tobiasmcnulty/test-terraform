resource "aws_vpc" "vpc" {
    cidr_block           = "172.31.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
    }
}

resource "aws_subnet" "subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block              = "172.31.32.0/20"
    availability_zone       = "${var.availability_zone}"
    map_public_ip_on_launch = true

    tags {
    }
}

