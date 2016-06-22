resource "aws_security_group" "sg-caktus-incoming" {
    name        = "caktus-incoming"
    description = "Allow all traffic from Caktus office & remote IPs"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["65.87.161.81/32", "70.62.97.170/32", "24.211.228.86/32", "45.37.85.230/32", "24.126.67.14/32"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "sg-incoming-ssh" {
    name        = "Incoming SSH"
    description = "Incoming SSH"
    vpc_id = "${aws_vpc.vpc.id}"
    ingress {
        from_port       = 22
        to_port         = 22
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

resource "aws_security_group" "sg-incoming-http" {
    name        = "Incoming HTTP & HTTPS"
    description = "Incoming HTTP & HTTPS"
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

resource "aws_security_group" "sg-cloudflare-incoming-https" {
    name        = "cloudflare-incoming-https"
    description = "Accept incoming SSL web traffic from Cloudflare"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/12", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17", "199.27.128.0/21"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
