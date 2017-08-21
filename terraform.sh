#! /usr/bin/env bash

cd terraform

terraform init -backend-config=qs.auto.tfvars -backend-config="profile=$AWS_DEFAULT_PROFILE" -plugin-dir=/terraform-plugins
terraform apply -var "profile=$AWS_DEFAULT_PROFILE"
