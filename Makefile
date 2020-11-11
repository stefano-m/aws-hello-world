
tf-version = 0.13.5
tf-arch = amd64

# linux, darwin, freebsd, solaris, windows
tf-os = linux

tf-artifact = terraform_$(tf-version)_$(tf-os)_$(tf-arch).zip
tf-shasums = terraform_$(tf-version)_SHA256SUMS

tf-download-url = https://releases.hashicorp.com/terraform/$(tf-version)

tf-workspace = development

.PHONY: help
# self-documenting Makefile
help:  ## print information about targets.
	@grep -E -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

terraform:  ## get the terraform binary.
	curl -L $(tf-download-url)/$(tf-shasums) -o $(tf-shasums)
	curl -L $(tf-download-url)/$(tf-artifact) -o $(tf-artifact)
	sha256sum --ignore-missing --check $(tf-shasums)
	unzip -o $(tf-artifact)
	chmod +x $@
	-rm -f $(tf-artifact) $(tf-shasums)

.PHONY: init
init: terraform  ## initialize terraform.
	./terraform $@ -input=false

.PHONY: fmt
fmt: terraform  ## format tf files.
	./terraform $@

.PHONY: validate
validate: terraform workspace  ## validate tf files.
	./terraform $@

.PHONY: workspace
workspace: terraform init  ## set up the terraform workspace. vars: tf-workspace
	./terraform $@ show | grep -x $(tf-workspace) \
	|| ./terraform $@ select $(tf-workspace) \
	|| ./terraform $@ new $(tf-workspace)


$(tf-workspace).tfplan:
	./terraform plan -input=false -out=$(tf-workspace).tfplan

.PHONY: plan
plan: $(tf-workspace).tfplan  ## plan the deployment. vars: tf-workspace

.PHONY: apply
apply: plan  ## apply the deployment, no questions asked. vars: tf-workspace
	./terraform $@ -compact-warnings -auto-approve $(tf-workspace).tfplan && rm -f $(tf-workspace).tfplan

.PHONY: output
output: terraform  ## print outputs saved by terraform. optional vars: $(tf-output-name)
	./terraform output $(tf-output-name)

.PHONY: check
check: test validate  ## validate and test.

.PHONY: test
test:  ## run the tests.
	./tests/test.sh

.PHONY: load-test
load-test: ## run the load tests. Look at the metrics once finished. optional vars: load-requests, load-processes
	MAX_REQUESTS=$(load-requests) MAX_PROCESSES=$(load-processes) ./tests/load_test.sh

.PHONY: clean-all
clean-all: destroy  ## remove everything, including the infrastructure!
	-rm -f $(tf-artifact) $(tf-shasums)
	-rm -rf .terraform
	-rm -rf *.tfplan

.PHONY: destroy
destroy: terraform workspace	 ## destroy the infrastructure. vars: tf-workspace
ifeq ($(tf-workspace), development)
	./terraform destroy -auto-approve
else
	./terraform destroy
endif
