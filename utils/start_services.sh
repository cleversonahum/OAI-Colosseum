#!/bin/bash

ip_address=$(ip a show col0 | grep -Po "\b(?:\d{1,3}\.){3}\d{1,3}\b")
third_octet=$(echo "$ip_address" | cut -d '.' -f 3)

source /root/OAI-Colosseum/utils/discover_function.sh
interface_name="col0"
total_nodes=3

result=$(get_host_index "$interface_name" "$total_nodes")
if [ "$result" = "1" ]; then
	echo "Enabling BS+Core services"
	systemctl enable --now /root/OAI-Colosseum/services/core_network.service
	systemctl enable --now /root/OAI-Colosseum/services/gnb.service
	systemctl link /root/OAI-Colosseum/services/iperf_server@.service
	for ((i = 1; i < total_nodes; i++)); do
		systemctl enable --now iperf_server@$i.service
	done
	systemctl enable --now /root/OAI-Colosseum/services/xapp_server.service
	systemctl enable --now /root/OAI-Colosseum/services/xapp_client.service
else
	echo "Enabling UE services"
	first_three_octets=$(echo $ip_address | cut -d '.' -f 1-3)
	gnb_ip="$first_three_octets.$third_octet"
	sd=$(($result%2 + 1))
	echo -e "GNB_IP=$gnb_ip\nSD=$sd\nNODE_IDX=$result" > /root/OAI-Colosseum/services/env.conf
	systemctl enable --now /root/OAI-Colosseum/services/ue.service
	systemctl enable --now /root/OAI-Colosseum/services/iperf_client.service
fi
