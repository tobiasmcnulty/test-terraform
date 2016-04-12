resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "web-instance" {
    ami = "${var.base_ami_id}"
    instance_type = "${var.web_instance_type}"

    subnet_id = "${aws_subnet.subnet.id}"

    # Allow ssh & http access
    vpc_security_group_ids = [
      "${aws_security_group.sg-caktus-incoming.id}",
      "${aws_security_group.sg-incoming-ssh.id}",
      "${aws_security_group.sg-incoming-http.id}"
    ]

    # The name of our SSH keypair we created above.
    key_name = "${aws_key_pair.auth.id}"
    connection {
       user = "ubuntu"
       type = "ssh"
    }

    # FIXME: we'll want to do something more sophisticated here
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -qq",
            "sudo shutdown -h now"
        ]
    }

    tags = {
         Name = "${var.project_name}-web-instance"
    }
}

resource "aws_ami_from_instance" "ami" {
    name = "${project_name}-ami"
    source_instance_id = "${aws_instance.web-instance.id}"
}

resource "aws_launch_configuration" "lc" {
    name_prefix = "web_config"
    image_id = "${aws_ami_from_instance.ami.id}"
    instance_type = "${var.web_instance_type}"
    security_groups = [
      "${aws_security_group.sg-caktus-incoming.id}",
      "${aws_security_group.sg-incoming-ssh.id}",
      "${aws_security_group.sg-incoming-http.id}"
    ]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ag" {
    desired_capacity          = "${var.desired_servers}"
    health_check_grace_period = 300
    health_check_type         = "ELB"
    launch_configuration      = "${aws_launch_configuration.lc.id}"
    max_size                  = "${var.max_servers}"
    min_size                  = "${var.min_servers}"
    name                      = "${var.project_name}-ag"
    vpc_zone_identifier       = ["subnet-9d36f9c5", "subnet-5f5da675"]  # FIXME

    tag {
        key   = "Name"
        value = "${var.project_name}_web"
        propagate_at_launch = true
    }
    tag {
        key   = "deployment"
        value = "${var.deployment}"
        propagate_at_launch = true
    }
    tag {
        key   = "environment"
        value = "${var.environment}"
        propagate_at_launch = true
    }
    tag {
        key   = "role"
        value = "web"
        propagate_at_launch = true
    }
}
