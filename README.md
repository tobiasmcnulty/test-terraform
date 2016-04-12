This is a *prototype* terraform configuration for
provisioning a set of resources on AWS to run
RapidPro.

Please don't take it as a recommended way of doing things,
just as an example of playing around with Terraform and
its documented AWS support.

Architecture:

  ELB -> Autoscaling group of web servers -> RDS (Postgres), Elasticache (Redis)
  S3

Terraform: https://www.terraform.io/

To use:

* Install terraform on your system: https://www.terraform.io/intro/getting-started/install.html
* Change to this directory
* Edit vars.tf
* Provide your AWS access key & secret, using environment variables or
  a configuration file: https://www.terraform.io/docs/providers/aws/index.html

To validate the syntax of all this:

* `terraform validate`

To see what terraform WOULD change if you ran this (dry run)

* `terraform plan`

This DOES access the servers, so make sure you've set credentials
(see above).

To actually run it (this will cost real money because it will
create resources on AWS):

* `terraform apply`

(I have not yet tried that.)


To limit the 'plan' or 'apply' to only parts of the config,
you can add one or more `-target=RESOURCENAME` to the command line,
where you get RESOURCENAME by looking for `resource` sections in
the config that look like this:

    resource "aws_blah_blah" "my_name" { ... }

Then RESOURCENAME would be "aws_blah_blah.my_name".  So:

* `terraform plan -target=aws_blah_blah.my_name`
