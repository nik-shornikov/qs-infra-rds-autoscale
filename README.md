# qs-infra-rds-autoscale

First, set up a AWS CLI profile and variables files:

  - ```terraform/<profile>.auto.tfvars```
  - ```terraform/<profile>.backend.auto.tfvars```

Now you can simply run:

```BUILD=$(uuidgen) AWS_DEFAULT_PROFILE=<profile> docker-compose up --build```
