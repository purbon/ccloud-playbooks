#!/usr/bin/env bash

set -xe

terraform apply -var-file="topics.tfvars" -parallelism=20
