# Configure the CloudFlare provider
provider "cloudflare" {
    email = "${var.cloudflare_email}"
    token = "${var.cloudflare_token}"
}

# Add a record to the domain
resource "cloudflare_record" "eb_subdomain" {
    domain = "${var.cloudflare_domain}"
    name = "${var.cloudflare_subdomain}"
    value = "${aws_elastic_beanstalk_environment.eb_env.cname}"
    type = "CNAME"
    ttl = 1 # set to 1 to avoid continually updating (not meaningful; TTL is auto-managed by cloudflare)
    proxied = true
}
