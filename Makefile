# Makefile for Terraform commands

init:
	terraform -chdir=terraform init

fmt:
	terraform -chdir=terraform fmt

plan:
	terraform -chdir=terraform plan

apply:
	terraform -chdir=terraform apply

destroy:
	terraform -chdir=terraform destroy