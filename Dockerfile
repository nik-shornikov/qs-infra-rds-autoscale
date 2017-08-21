FROM ubuntu:16.04
MAINTAINER Nikolai Shornikov

RUN apt-get -qq update
RUN apt-get install -y python-setuptools python-dev build-essential ca-certificates wget zip jq
RUN easy_install pip
RUN pip install awscli --upgrade

RUN wget --quiet -O terraform.zip https://releases.hashicorp.com/terraform/0.10.2/terraform_0.10.2_linux_amd64.zip
RUN unzip terraform.zip -d terraformbin
RUN mv terraformbin/terraform /usr/local/bin/

RUN wget --quiet -O terraformaws.zip https://releases.hashicorp.com/terraform-provider-aws/0.1.4/terraform-provider-aws_0.1.4_linux_amd64.zip
RUN mkdir /terraform-plugins
RUN unzip terraformaws.zip -d /terraform-plugins

COPY apex /apex
COPY terraform /terraform
COPY terraform.sh /
