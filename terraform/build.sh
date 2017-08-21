#! /usr/bin/env bash

while [ ! -f /tmp/$BUILD/report.zip ];
do
  echo 'waiting for report package'
  sleep 2
done;

sleep 2

terraform init -backend-config=$PROFILE.backend.auto.tfvars -backend-config="profile=$PROFILE" -plugin-dir=/terraform-plugins
terraform apply -var "profile=$PROFILE" -var "build=$BUILD"
