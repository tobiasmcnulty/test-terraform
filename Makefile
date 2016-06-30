.DEFAULT_GOAL := help
.PHONY: help deps get init validate plan apply refresh destroy destroy_force

ENV_DIR := ${ENV}
AWS_PROFILE := ${APP}-${ENV}
TF_STATE_BUCKET := ${APP}-${ENV}-terraform-state
TERRAFORM_BIN := terraform
REGION := us-east-1
OPTS ?=

help:
	@echo "Builds the taytay infrastructure"
	@echo ""
	@echo "Targets:"
	@echo "  apply  Commits the plan against the infrastructure"
	@echo "  deps   Ensures system requirements are met"
	@echo "  help   This message"
	@echo "  plan   Builds a new Terraform plan file"

deps:
	@hash $(TERRAFORM_BIN) > /dev/null 2>&1 || \
		(echo "Install terraform to continue"; exit 1)
	@test -n "$(AWS_ACCESS_KEY_ID)" || \
		(echo "AWS_ACCESS_KEY_ID env not set"; exit 1)
	@test -n "$(AWS_SECRET_ACCESS_KEY)" || \
		(echo "AWS_SECRET_ACCESS_KEY env not set"; exit 1)

get:
	cd $(ENV_DIR) && AWS_PROFILE=$(AWS_PROFILE) $(TERRAFORM_BIN) get

init : get
	cd $(ENV_DIR) && AWS_PROFILE=$(AWS_PROFILE) $(TERRAFORM_BIN) apply \
		-var-file=../secrets.tfvars \
		-var 'bucket_name=$(TF_STATE_BUCKET)' \
		-target=module.state.aws_s3_bucket.terraform_state
	cd $(ENV_DIR) && AWS_PROFILE=$(AWS_PROFILE) $(TERRAFORM_BIN) remote config \
		-backend=s3 -pull=false \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=${APP}-${ENV}.tfstate" \
		-backend-config="region=$(REGION)"

validate plan apply refresh destroy : get
	cd $(ENV_DIR) && AWS_PROFILE=$(AWS_PROFILE) $(TERRAFORM_BIN) $@ \
		-var-file=../secrets.tfvars \
		-target=module.${APP}-${ENV} ${OPTS}
