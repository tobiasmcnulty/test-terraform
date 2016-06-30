/*
  DECLARE variables and set default values.
  Set actual values for secrets in <environment>.tfvars or secrets.tfvars.
  TBD: where to set actual (not default) values for non-secrets - here? Another tfvars file?
*/

variable "app_name" {
    type = "string"
    description = "A unique application name, e.g., myproject. Will be used to name all AWS resources."
}

variable "env_name" {
    type = "string"
    description = "A unique environment name, e.g., staging or production. Will be used to name all AWS resources."
}

variable "aws_region" { default = "us-east-1" }
variable "aws_az_0" { default = "c" }
variable "aws_az_1" { default = "d" }

/* ELB/incoming */
variable "certificate_file" {
         default = "server.crt"
         description = "SSL certificate for the site"
}
variable "key_file" {
         default = "server.key"
         description = "SSL key file for the site"
}

/* RDS/Elasticache/Redis */
variable "redis_node_type" { default = "cache.t2.micro" }

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
variable "max_servers" { default = 4 }
variable "min_servers" { default = 1 }
variable "web_instance_type" { default = "t2.micro" }

variable "key_name" {
         default = ""
         description = "Import an existing AWS key pair for access to EC2 servers and give it this name. Leave empty to leave ssh access to servers disabled."
}
variable "public_key_path" {
         default = "dummy.pem"
         description = "Path to file with public part of the AWS key pair that you're going to import to AWS and use to access the EC2 servers"
}

variable "django_secret_key" {
    type = "string"
    description = "SECRET_KEY to use for Django. Define in your secrets.tfvars."
}

/* CloudFlare configuration (used for DNS + SSL termination) */
variable "cloudflare_email" {
    type = "string"
    desscription = "Email for cloudflare account"
}
variable "cloudflare_token" {
    type = "string"
    description = "Global API access token for Cloudflare account"
}
variable "cloudflare_domain" {
    type = "string"
    description = "TLD to use with CloudFlare. Must already exist in the account."
}
variable "cloudflare_subdomain" {
    type = "string"
    description = "Just the sub portion of the domain. Will be created by TerraForm."
}
