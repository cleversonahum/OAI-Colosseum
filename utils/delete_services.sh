#!/bin/bash

source /share/config/rl_ran_slicing/scenario.env

systemctl disable --now start_network.service
echo "Disabling BS+Core services"
systemctl disable --now core_network.service
docker rm -f $(docker ps -qa)
systemctl disable --now gnb.service iperf_server@ xapp_server xapp_client

#iperf_servers=$(($total_nodes-1))
#while [ $iperf_servers -ne 0 ]; do
#	systemctl disable --now iperf_server@$iperf_servers
#	((iperf_servers--))  # Reduce the value of iperf_servers by one
#done

echo "Disabling UE services"
systemctl disable --now ue iperf_client
