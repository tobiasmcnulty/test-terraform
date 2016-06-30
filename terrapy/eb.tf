resource "aws_elastic_beanstalk_application" "eb_app" {
  # EB expects this to be the same for all environments
  name = "${var.app_name}-app"
  description = "${var.app_name} Elastic Beanstalk app"
}

/* SSL certificate -- disabled while we work on Let's Encrypt support */
#resource "aws_iam_server_certificate" "eb_cert" {
#    name = "${var.app_name}-${var.env_name}-cert"
#    certificate_body = "${file("${var.certificate_file}")}"
#    private_key = "${file("${var.key_file}")}"
#}

resource "aws_elastic_beanstalk_environment" "eb_env" {
  name = "${var.app_name}-${var.env_name}-env"
  application = "${aws_elastic_beanstalk_application.eb_app.name}"
  solution_stack_name = "64bit Amazon Linux 2016.03 v2.1.0 running Python 3.4"
  cname_prefix = "${var.app_name}-${var.env_name}-env" # Must be unique. Be sure to update ALLOWED_HOSTS below too.
  tier = "WebServer"

  /* VPC Settings */
  setting = {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = "${aws_vpc.vpc.id}"
  }
  # put instances and ELBs together in the same subnets
  setting = {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.subnet_0.id},${aws_subnet.subnet_1.id}"
  }
  setting = {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.subnet_0.id},${aws_subnet.subnet_1.id}"
  }
  # required when instances and ELBs are in a public subnet together
  setting = {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }

  /* AG Settings */
  setting = {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "${var.min_servers}"
  }
  setting = {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "${var.max_servers}"
  }

  /* LC Settings */
  setting = {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${var.key_name}"
  }
  setting = {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups" # place web instances in these SGs (used to allow connections to DB)
    value = "${aws_security_group.sg_web.id}"
  }
  setting = {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.web_instance_type}"
  }
  setting = {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile" # supposedly speeds up deploys
    value = "${aws_iam_instance_profile.eb_inst_profile.name}"
  }

  /* Load Balancer Settings */
  setting = {
    namespace = "aws:elb:loadbalancer"
    name = "SecurityGroups" # place ELBs in these SGs (allow connections only from CloudFlare)
    value = "${aws_security_group.sg_elb.id}"
  }
  setting = {
    namespace = "aws:elb:loadbalancer"
    name = "ManagedSecurityGroup" # place ELBs in these SGs (allow connections only from CloudFlare)
    value = "${aws_security_group.sg_elb.id}"
  }

  /* Listener Settings -- disabled while we work on Let's Encrypt support  */
  #setting = {
  #  namespace = "aws:elb:listener:443"
  #  name = "ListenerProtocol"
  #  value = "HTTPS"
  #}
  #setting = {
  #  namespace = "aws:elb:listener:443"
  #  name = "SSLCertificateId"
  #  value = "${aws_iam_server_certificate.eb_cert.arn}"
  #}
  # For now, terminate SSL at the LB and use HTTP to talk to backend servers
  # See http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/https-singleinstance-python.html
  # to enable SSL terminate at the instances
  #setting = {
  #  namespace = "aws:elb:listener:443"
  #  name = "InstanceProtocol"
  #  value = "HTTP"
  #}
  #setting = {
  #  namespace = "aws:elb:listener:443"
  #  name = "InstancePort"
  #  value = "80"
  #}

  /* Elastic Beanstalk Platform Settings */
  setting = {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole" # allows AWS to reboot our instances with security updates
    value = "${aws_iam_role.eb_service_role.name}" # should be created by EB by default
  }
  setting = {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType" # required for managed updates
    value = "enhanced"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "ManagedActionsEnabled" # required for managed updates
    value = "true"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "PreferredStartTime"
    value = "Sun:02:00"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "UpdateLevel"
    value = "minor" # or "patch" ("minor" provides more updates)
  }
  setting = {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "InstanceRefreshEnabled"
    value = "true" # refresh instances weekly
  }

  /* Django App Settings to add to the Elastic Beanstalk environment */
  setting = {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DEBUG"
    value = "off"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SSL"
    value = "off" # auto redirect to HTTPS in Django
  }
  setting = {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SECRET_KEY"
    value = "${var.django_secret_key}"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DATABASE_URL"
    value = "postgres://${aws_db_instance.rds.username}:${aws_db_instance.rds.password}@${aws_db_instance.rds.address}:${aws_db_instance.rds.port}/postgres"
  }
  setting = {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "ALLOWED_HOSTS"
    # may need to be manually fixed; no way to pass ${self.cname}
    value = "localhost;${var.app_name}-${var.env_name}-env.${var.aws_region}.elasticbeanstalk.com;${var.cloudflare_subdomain}.${var.cloudflare_domain}"
  }
}
