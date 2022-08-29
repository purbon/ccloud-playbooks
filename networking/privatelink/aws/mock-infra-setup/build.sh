#!/usr/bin/env bash

set -xe

time terraform apply -var-file="is.tfvars" -parallelism=20
