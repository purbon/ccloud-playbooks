#!/usr/bin/env bash

# List RBAC roles

$> confluent iam rbac rb list --principal sa-o3rd7p --cloud-cluster lkc-9kwjny --environment env-j9wgp

# List Confluent ACL list

$> confluent kafka acl list
