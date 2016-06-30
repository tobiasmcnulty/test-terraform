provider "aws" {
    region = "us-east-1"
}

module "taytay-production" {
    source = "../terrapy"

    app_name = "taytay"
    env_name = "production"

    cloudflare_email = "tobias+ecr@caktusgroup.com"
    cloudflare_domain = "caktus-built.com"
    cloudflare_subdomain = "taytay"
    cloudflare_token = "${var.cloudflare_token}"

    rds_master_password = "${var.rds_master_password}"

    django_secret_key = "${var.django_secret_key}"

    aws_az_0 = "c"
    aws_az_1 = "b"
}

module "state" {
    source = "../terrapy_state"

    bucket_name = "taytay-production-terraform-state"
}
