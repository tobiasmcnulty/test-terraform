provider "aws" {
    region = "us-east-1"
}

module "taytay-staging" {
    source = "../terrapy"

    app_name = "taytay"
    env_name = "staging"

    cloudflare_email = "tobias+ecr@caktusgroup.com"
    cloudflare_domain = "caktus-built.com"
    cloudflare_subdomain = "taytay-staging"
    cloudflare_token = "${var.cloudflare_token}"

    rds_master_password = "${var.rds_master_password}"

    django_secret_key = "${var.django_secret_key}"
}

module "state" {
    source = "../terrapy_state"

    # not sure why this is needed; should be able to pass in via -var
    bucket_name = "taytay-staging-terraform-state"
}
