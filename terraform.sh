#! /usr/bin/env bash

cd terraform

terraform init -backend-config=$PROFILE.backend.auto.tfvars -backend-config="profile=$PROFILE" -plugin-dir=/terraform-plugins
terraform apply -var "profile=$PROFILE"
