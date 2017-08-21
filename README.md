# qs-infra-rds-autoscale

First, set up a AWS CLI profile and variables files:

  - ```terraform/<profile>.auto.tfvars```
  - ```terraform/<profile>.backend.auto.tfvars```

```VARS_FILE=<your vars file under terraform> AWS_DEFAULT_PROFILE=<profile name> docker-compose up --build```
