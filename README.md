[![CircleCI](https://circleci.com/gh/tobiasmcnulty/test-terraform/tree/elastic-beanstalk.svg?style=svg)](https://circleci.com/gh/tobiasmcnulty/test-terraform/tree/elastic-beanstalk)

This is a *prototype* Terraform configuration for
provisioning a set of resources on AWS to run
https://github.com/caktus/taytay.

Please don't take it as a recommended way of doing things,
just as an example of playing around with Terraform and
its documented AWS support.

Architecture:

  Elastic Beanstalk -> RDS (Postgres), Elasticache (Redis)

Terraform: https://www.terraform.io/

To use:

* Install terraform on your system: https://www.terraform.io/intro/getting-started/install.html
* Change to this directory
* Copy secrets.tfvars-example to secrets.tfvars
* Edit secrets.tfvars
* Edit `<environment>/main.tf`
* Provide your AWS access key & secret, using a configuration file:
  https://www.terraform.io/docs/providers/aws/index.html.
  The included `Makefile` relies on the existence of a profile in
  `~/.aws/credentials` that is identical to `<app_name>-<env_name>`, as defined
  in `<environment>/main.tf`. It works by setting the `AWS_PROFILE`
  environment variable to the correct account before running any commands
  Separate AWS accounts are expected, but not required, for staging and
  production.

The first thing we'll do with TerraForm is setup and configure remote
storage for its state files and pull in our `terrapy` module:

* `make APP=taytay ENV=staging init`

If that command completes successfully, we'll have a link set up to a remote
copy of the `*.tfstate` file that others can collaborate with us on. See the
`<environment>/.terraform` directory.

To validate the syntax of all local files:

* `make APP=taytay ENV=staging validate`

To see what terraform WOULD change if you ran this (dry run):

* `make APP=taytay ENV=staging plan`

This DOES access the servers, so make sure you've set credentials
(see above).

To actually run it (this may cost real money because it will
create resources on AWS, though by default everything should be
free tier-eligible, if you're on a new account):

* `make APP=taytay ENV=staging apply`

Once the environment is setup correctly, you can deploy the code with
the Elastic Beanstalk CLI:

    git clone https://github.com/caktus/taytay.git
    mkvirtualenv -p python3.4 taytay
    pip install -U awsebcli
    eb init --profile=taytay-staging

Supposedly awsebcli doesn't work with Python 3.5, but it seems to work okay
as a backup if you don't have 3.4 handy. The last command will prompt you
for several inputs:

* Make sure to select the existing app (`taytay-app`).
* Do NOT set up SSH access at this stage (it's not necessary yet and will
  add complication).

**Note:** the `awsebcli` does not play nicely if you have quotes around your
`access_key_id` and `aws_secret_access_key` in `.aws/credentials`. Make sure
you create this file without quotations (TerraForm works either way).

The final step before deploying is to add a config file to tell Elastic
Beanstalk about our Python app. Save the following in `.ebextensions/django.config`
(really any file ending in `.config` will do):

    packages:
      yum:
        postgresql93-devel: []
        libjpeg-turbo-devel: []
        libpng-devel: []
        freetype-devel: []
        libxslt-devel: []
        libxml2-devel: []
    option_settings:
      "aws:elasticbeanstalk:container:python":
        WSGIPath: taytay/wsgi.py
        NumProcesses: 8
        NumThreads: 1
      "aws:elasticbeanstalk:container:python:staticfiles":
        "/static/": "public/static/"
    container_commands:
      00_dotenv:
        command: "ln -s ../env .env"
      01_migrate:
        command: "/opt/python/run/venv/bin/python manage.py migrate --noinput"
        leader_only: true
      02_collectstatic:
        command: "/opt/python/run/venv/bin/python manage.py collectstatic --noinput"

After saving this file, **you must commit it to the repo** (pushing is not
necessary).

Once you have the environment set up (`eb init` will store its files in
`.elasticbeanstalk/config.yml`), deploy the app:

    eb deploy --profile=taytay-staging taytay-staging-env
