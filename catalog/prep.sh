#!/usr/bin/env bash

confluent kafka cluster use $CLUSTER_ID

confluent kafka topic create foo
confluent kafka topic create bar

confluent schema-registry schema create --subject foo-value --schema foo.avsc --type AVRO \
                                        --api-key $SCHEMA_REGISTRY_API_KEY --api-secret $SCHEMA_REGISTRY_API_SECRET

confluent schema-registry schema create --subject bar-value --schema bar.avsc --type AVRO \
                                        --api-key $SCHEMA_REGISTRY_API_KEY --api-secret $SCHEMA_REGISTRY_API_SECRET

confluent iam rbac role-binding list --principal $CCLOUD_PRINCIPAL


confluent iam rbac role-binding create --principal $CCLOUD_PRINCIPAL \
                                       --role CloudClusterAdmin \
                                       --environment $CCLOUD_ENV --cloud-cluster $CLUSTER_ID --kafka-cluster-id $CLUSTER_ID


                                       confluent iam rbac role-binding create --principal $CCLOUD_PRINCIPAL \
                                                                              --role CloudClusterAdmin \
                                                                              --environment $CCLOUD_ENV --kafka-cluster-id $CLUSTER_ID
