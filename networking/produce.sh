#!/usr/bin/env bash

source .env

cat msgs.txt | kcat -b lkc-w7x1z5-g0420p.eu-west-1.aws.glb.confluent.cloud:9092 \
 -X security.protocol=sasl_ssl -X sasl.mechanisms=PLAIN \
 -X sasl.username=$CCLOUD_API_KEY  -X sasl.password=$CCLOUD_API_SECRET  \
 -t $1 -P
