#!/usr/bin/env bash
set -xe

terraform apply -var-file="mt.tfvars" -parallelism=20
