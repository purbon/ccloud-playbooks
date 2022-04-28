#!/usr/bin/env bash

# List RBAC roles

$> confluent iam rbac rb list --principal User:sa-w7dd05 --cloud-cluster lkc-223xxq --environment env-j9wgp

# List Confluent ACL list

$> confluent kafka acl list
