#!/usr/bin/env bash

sudo apt install squid
sudo cp -v /etc/squid/squid.conf{,.factory}


sudo systemctl enable squid.service


iptables -t nat -A OUTPUT --match owner --uid-owner proxy -p tcp --dport 80 -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 10.0.10.5:3128

iptables -S


iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner proxy --dport 80 -j REDIRECT --to-port 3128



iptables -t nat -A PREROUTING -i ens5 -s ! 10.0.10.5 -p tcp --dport 80 -j DNAT --to 10.0.10.5:3128
iptables -t nat -A POSTROUTING -o ens5 -s 10.0.10.0/24 -d 10.0.10.5 -j SNAT --to 10.0.10.5
iptables -A FORWARD -s 10.0.10.0/24 -d  10.0.10.5  -i ens5 -o ens5 -p tcp --dport 3128 -j ACCEPT


curl http://eu.httpbin.org/get
curl https://confluent.cloud

export http_proxy="http://10.0.10.5:3128"
export https_proxy="http:/10.0.10.5:3128"
