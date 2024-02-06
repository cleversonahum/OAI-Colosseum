#!/bin/bash


systemctl disable --now start_network.service
echo "Disabling BS+Core services"
systemctl disable --now core_network.service
docker rm -f $(docker ps -qa)
systemctl disable --now gnb.service iperf_server@ iperf_server@1 iperf_server@2 xapp_server xapp_client
echo "Disabling UE services"
systemctl disable --now ue iperf_client
