resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.app_name}-${var.env_name}-gw"
    }
}

resource "aws_vpc" "vpc" {
    cidr_block           = "172.31.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        Name = "${var.app_name}-${var.env_name}-vpc"
    }
}

resource "aws_subnet" "subnet_0" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block              = "172.31.32.0/20"
    availability_zone       = "${var.aws_region}${var.aws_az_0}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.app_name}-${var.env_name}-subnet-0"
    }
}

resource "aws_subnet" "subnet_1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block              = "172.31.48.0/20"
    availability_zone       = "${var.aws_region}${var.aws_az_1}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.app_name}-${var.env_name}-subnet-1"
    }
}

resource "aws_route_table" "public_route" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "subnet_0" {
    subnet_id = "${aws_subnet.subnet_0.id}"
    route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "subnet_1" {
    subnet_id = "${aws_subnet.subnet_1.id}"
    route_table_id = "${aws_route_table.public_route.id}"
}
