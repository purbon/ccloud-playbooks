#!/usr/bin/env bash


java -jar julie-ops.jar --brokers pkc-ldvmy.centralus.azure.confluent.cloud:9092 \
                        --clientConfig config.properties \
                        --topology topologies/descriptor.yml --dryRun --quiet
