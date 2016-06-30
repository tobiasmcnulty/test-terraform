resource "aws_security_group" "sg_db" {
    name        = "${var.app_name}-${var.env_name}-db-sg"
    description = "Database server SG"
    vpc_id = "${aws_vpc.vpc.id}"
    ingress {
        from_port       = 0
        to_port         = 5432
        protocol        = "tcp"
        security_groups = ["${aws_security_group.sg_web.id}"]
    }
}

resource "aws_security_group" "sg_web" {
    name        = "${var.app_name}-${var.env_name}-web-sg"
    description = "Web server SG"
    vpc_id = "${aws_vpc.vpc.id}"
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

# based on http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-endtoend.html
resource "aws_security_group" "sg_elb" {
    name        = "${var.app_name}-${var.env_name}-elb-sg"
    description = "Load Balancer SG"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port       = 0
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        # Following are CloudFlare IPs. Lock down if needed, however, note this will break Let's Encrpyt auto-renewal.
        #cidr_blocks     = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/12", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17", "199.27.128.0/21"]
    }
    ingress {
        from_port       = 0
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"] # swap in for debugging if needed
        # Following are CloudFlare IPs. Lock down if needed, however, note this will break Let's Encrpyt auto-renewal.
        #cidr_blocks     = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/12", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17", "199.27.128.0/21"]
    }
    egress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
