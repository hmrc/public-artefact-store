SHELL := /bin/bash

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: init_labs
init_labs: clean
	terraform init -backend-config="bucket=mdtp-terraform-public-artefact-store-labs"

.PHONY: init_live
init_live: clean
	terraform init -backend-config="bucket=mdtp-terraform-public-artefact-store-live"
