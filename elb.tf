# SSL certificate
resource "aws_iam_server_certificate" "ssl-cert" {
    name = "${var.project_name}-cert"
    certificate_body = "${file("${var.certificate_file}")}"
    private_key = "${file("${var.key_file}")}"
}


resource "aws_elb" "elb" {
    name                        = "${var.project_name}-lb"
    subnets                     = ["${aws_subnet.subnet.id}"]
    security_groups             = ["sg-cloudflare-incoming-https"]
    instances                   = ["i-7cdbe9fc"]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 35

    listener {
        instance_port      = 443
        instance_protocol  = "https"
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = "${aws_iam_server_certificate.ssl-cert.id}"
    }

    listener {
        instance_port      = 80
        instance_protocol  = "http"
        lb_port            = 80
        lb_protocol        = "http"
        ssl_certificate_id = ""
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 30
        target              = "HTTPS:443/healthcheck.html"
        timeout             = 5
    }

    tags {
        deployment = "${var.deployment}"
        environment = "${var.environment}"
        role = "loadbalancer"
    }
}


output "elb_hostname" {
       value = "${aws_elb.elb.dns_name}"
}
