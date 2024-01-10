#!/bin/bash

source /root/OAI-Colosseum/utils/discover_function.sh
interface_name="col0"
result=$(get_host_index "$interface_name")

systemctl disable --now start_network.service
if [ "$result" = "1" ]; then
	echo "Disabling BS+Core services"
	systemctl disable --now core_network.service
	docker rm -f $(docker ps -qa)
	systemctl disable --now gnb.service
	systemctl disable --now iperf_server
	systemclt disable --now xapp_server
	systemctl disable --now xapp_client
else
	echo "Disabling UE services"
	systemctl disable --now ue.service
	systemctl disable --now iperf_client.service
fi
