# qs-infra-rds-autoscale

First, set up a AWS CLI profile and variables files:

  - ```terraform/<profile>.backend.auto.tfvars```
  - ```terraform/<profile>.auto.tfvars```

Always ensure that the above are not accidentally tracked in git.

Now you can simply run:

```BUILD=$(uuidgen) AWS_DEFAULT_PROFILE=<profile> docker-compose up --build```
