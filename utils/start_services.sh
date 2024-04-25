#!/bin/bash

source /root/OAI-Colosseum/utils/discover_function.sh
source /share/config/rl_ran_slicing/scenario.env

result=$(get_host_index "$interface_name" "$total_nodes")
echo "Node idx $result"

ip_address=$(ip a show col0 | grep -Po "\b(?:\d{1,3}\.){3}\d{1,3}\b")
third_octet=$(echo "$ip_address" | cut -d '.' -f 3)

# Cloning/updating git repos
/usr/bin/bash -c "/root/OAI-Colosseum/utils/set_internet_access.sh && git -C /root/Openairinterface pull origin NR_Slicing && git -C /root/xapp_sched_rlagent pull origin main && git -C /root/OAI-Colosseum pull origin main"  

systemctl enable --now /root/OAI-Colosseum/services/rf_scenario.service
systemctl enable --now /root/OAI-Colosseum/services/flash_usrp.service
if [ "$result" = "1" ]; then
	echo "Enabling BS+Core services"
	# Copy pre-trained agent if it exists
	mkdir -p /logs/rl_ran_slicing/
	cp /share/config/rl_ran_slicing/scenario.env /logs/rl_ran_slicing/
	cp -r /share/config/rl_ran_slicing/agent/$scenario_name/$rl_agent_name/ray_results/ /logs/rl_ran_slicing/
	systemctl enable --now /root/OAI-Colosseum/services/core_network.service
	systemctl enable --now /root/OAI-Colosseum/services/gnb.service
	systemctl link /root/OAI-Colosseum/services/iperf_server@.service
	for ((i = 1; i < total_nodes; i++)); do
		systemctl enable --now iperf_server@$i.service
	done
	if [ "$test_mode" -eq "0" ]; then
		systemctl enable --now /root/OAI-Colosseum/services/xapp_server.service
	fi
	systemctl enable --now /root/OAI-Colosseum/services/xapp_client.service
else
	echo "Enabling UE services"
	first_three_octets=$(echo $ip_address | cut -d '.' -f 1-3)
	gnb_ip="$first_three_octets.$third_octet"
	if [ "$(($result - 1))" -le "$ues_slice_1" ]; then
		sd=1
		thr_ue=$requested_thr_slice_1
	else
		sd=2
		thr_ue=$requested_thr_slice_2
	fi
	echo -e "HOME=/root/\nGNB_IP=$gnb_ip\nSD=$sd\nNODE_IDX=$result\nTHR_UE=$thr_ue" > /root/OAI-Colosseum/services/env.conf
	systemctl enable --now /root/OAI-Colosseum/services/ue.service
	systemctl enable --now /root/OAI-Colosseum/services/iperf_client.service
fi
