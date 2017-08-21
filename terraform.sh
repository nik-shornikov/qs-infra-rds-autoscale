#! /usr/bin/env bash

cd terraform

terraform init -backend-config=$VARS_FILE -backend-config="profile=$AWS_DEFAULT_PROFILE" -plugin-dir=/terraform-plugins
terraform apply -var "profile=$AWS_DEFAULT_PROFILE"
