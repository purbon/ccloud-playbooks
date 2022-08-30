#!/usr/bin/env bash

sudo apt-get install haproxy
sudo apt install -y rsyslog


touch /var/lib/haproxy/dev/log
mount --bind /dev/log /var/lib/haproxy/dev/log
