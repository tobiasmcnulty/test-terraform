/*
  DECLARE variables and set default values.
  Set actual values for secrets in secrets.tfvars.
  TBD: where to set actual (not default) values for non-secrets - here? Another tfvars file?
 */

variable "project_name" { default = "tftest-rapidpro" }
variable "environment" { default = "pycon" }
variable "deployment" { default = "rapidpro" }

variable "aws_region" { default = "us-east-1" }
variable "availability_zone" { default = "us-east-1c" }

/* ELB/incoming */
variable "certificate_file" {
         default = "server.crt"
         description = "SSL certificate for the site"
}
variable "key_file" {
         default = "server.key"
         description = "SSL key file for the site"
}

/* Elasticache/Redis */
variable "redis_node_type" { default = "cache.t2.micro" }

/* RDS */
variable "rds_master_password" {
    type = "string"
    description = "Password to set on the RDS master user. If you're being prompted for this at runtime, then Control-C out and run your command again, adding -var-file=secrets.tfvars to the command line."
}
variable "rds" {
    type = "map"
    default = {
        master_username = "master"
        instance_type = "db.t2.micro"
        storage = "10"
        postgres_version = "9.5.2"
    }
}

/* Web/autoscaling */
variable "max_servers" { default = 2 }
variable "min_servers" { default = 1 }
variable "desired_servers" { default = 1 }
variable "base_ami_id" {
         default = "ami-13be557e"
         description = "AMI ID of the instance to start with when provisioning an image for the web servers"
}
variable "web_instance_type" { default = "t2.micro" }

variable "key_name" {
         default = "ec2_key_pair"
         description = "Import an existing AWS key pair for access to EC2 servers and give it this name"
}
variable "public_key_path" {
         default = "dummy.pem"
         description = "Path to file with public part of the AWS key pair that you're going to import to AWS and use to access the EC2 servers"
}
