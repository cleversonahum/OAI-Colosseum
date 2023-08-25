#!/bin/bash
ip r a default via 172.18.2.1
echo "nameserver 10.100.11.53" > /etc/resolv.conf
