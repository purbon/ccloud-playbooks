#!/usr/bin/env bash

set -xe

time terraform apply -var-file="ccp.tfvars" -parallelism=20
