#!/bin/bash

source ../../event.env && python-lambda-local -f $1 $2 $3
