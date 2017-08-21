FROM ubuntu:16.04
MAINTAINER Nikolai Shornikov

RUN apt-get -qq update
RUN apt-get install -y python-setuptools python-dev build-essential ca-certificates wget zip jq curl
RUN easy_install pip
RUN pip install awscli --upgrade

RUN curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh

RUN apex upgrade

COPY . /apex

WORKDIR /apex

CMD /apex/build.sh
