#!/bin/bash

python --version

source ../../event.env && python-lambda-local -f $1 $2 $3
