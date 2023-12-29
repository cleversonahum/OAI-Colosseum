#!/bin/bash

ip_address=$(ip a show col0 | grep -Po "\b(?:\d{1,3}\.){3}\d{1,3}\b")
third_octet=$(echo "$ip_address" | cut -d '.' -f 3)
fourth_octet=$(echo "$ip_address" | cut -d '.' -f 4)
abs_path=$(pwd)

if [ "$third_octet" = "$fourth_octet" ]; then
	echo "Enabling BS+Core services"
	systemctl enable --now $abs_path/services/internet.service
	systemctl enable --now $abs_path/services/core_network.service
	systemctl enable --now $abs_path/services/gnb.service
else
	echo "Enabling UE services"
	gnb_ip=$(echo $ip_adddress | awk -F'.' -v var="$third_octet" '{OFS="."} {$4=var; print}')
	echo "GNB_IP=$gnb_ip" > /root/OAI-Colosseum/services/gnb.conf
	systemctl enable --now $abs_path/services/internet.service
	systemctl enable --now $abs_path/services/ue.service
fi
