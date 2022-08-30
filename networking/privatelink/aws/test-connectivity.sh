#!/usr/bin/env bash

nc -zv lkc-w7x1z5-g0420p.eu-west-1.aws.glb.confluent.cloud 9092
nc -zv lkaclkc-w7x1z5-g0420p.eu-west-1.aws.glb.confluent.cloud 9092

openssl s_client -connect lkc-w7x1z5-g0420p.eu-west-1.aws.glb.confluent.cloud:9092

openssl s_client -connect lkaclkc-w7x1z5-g0420p.eu-west-1.aws.glb.confluent.cloud:443
