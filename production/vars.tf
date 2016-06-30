
variable "django_secret_key" {
    type = "string"
    description = "SECRET_KEY to use for Django. Define in your secrets.tfvars."
}

variable "cloudflare_token" {
    type = "string"
    description = "Global API access token for Cloudflare account"
}

variable "rds_master_password" {
    type = "string"
    description = "Password to set on the RDS master user. If you're being prompted for this at runtime, then Control-C out and run your command again, adding -var-file=secrets.tfvars to the command line."
}
