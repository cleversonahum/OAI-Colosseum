#!/bin/bash

ip_address=$(ip a show col0 | grep -Po "\b(?:\d{1,3}\.){3}\d{1,3}\b")
third_octet=$(echo "$ip_address" | cut -d '.' -f 3)
fourth_octet=$(echo "$ip_address" | cut -d '.' -f 4)

systemctl disable --now start_network.service
if [ "$third_octet" = "$fourth_octet" ]; then
	echo "Disabling BS+Core services"
	systemctl disable --now core_network.service
	docker rm -f $(docker ps -qa)
	systemctl disable --now gnb.service
	systemctl disable --now iperf_server
else
	echo "Disabling UE services"
	systemctl disable --now ue.service
	systemctl disable --now iperf_client.service
fi
