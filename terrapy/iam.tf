/*
  our own implementation of aws-elasticbeanstalk-ec2-role
  http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles.html#concepts-roles-instance
  create it here since the role doesn't exist by default on new accounts
*/

resource "aws_iam_role" "eb_inst_role" {
    name = "${var.app_name}-${var.env_name}-eb-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "web_attach" {
    name = "${var.app_name}-${var.env_name}-policy-web-attach"
    roles = ["${aws_iam_role.eb_inst_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "docker_attach" {
    name = "${var.app_name}-${var.env_name}-policy-docker-attach"
    roles = ["${aws_iam_role.eb_inst_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_policy_attachment" "worker_attach" {
    name = "${var.app_name}-${var.env_name}-policy-worker-attach"
    roles = ["${aws_iam_role.eb_inst_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_instance_profile" "eb_inst_profile" {
    name = "${var.app_name}-${var.env_name}-eb-ec2-profile"
    roles = ["${aws_iam_role.eb_inst_role.name}"]
}

/* allow our servers to manage their own SSL certs via Let's Encrypt */
resource "aws_iam_role_policy" "eb_inst_cert_mgmt" {
    name = "${var.app_name}-${var.env_name}-eb-cert-mgmt-policy"
    role = "${aws_iam_role.eb_inst_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:SetLoadBalancerListenerSSLCertificate",
                "elasticloadbalancing:CreateLoadBalancerListeners"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "iam:UploadServerCertificate",
                "iam:DeleteServerCertificate"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

/*
  our own implementation of aws-elasticbeanstalk-service-role
  http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/iam-servicerole.html
  create it here since the role doesn't exist by default on new accounts
*/

resource "aws_iam_role" "eb_service_role" {
    name = "${var.app_name}-${var.env_name}-eb-service-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticbeanstalk.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "elasticbeanstalk"
          }
        }
      }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "health_attach" {
    name = "${var.app_name}-${var.env_name}-policy-health-attach"
    roles = ["${aws_iam_role.eb_service_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "service_attach" {
    name = "${var.app_name}-${var.env_name}-policy-service-attach"
    roles = ["${aws_iam_role.eb_service_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
