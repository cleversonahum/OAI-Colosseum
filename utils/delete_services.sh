#!/bin/bash

source /share/config/rl_ran_slicing/scenario.env

systemctl disable --now start_network.service
echo "Disabling BS+Core services"
systemctl disable --now core_network.service
systemctl disable --now gnb.service iperf_server@ xapp_server xapp_client
docker compose -f /root/OAI-Colosseum/core/docker-compose-mini-nrf.yaml down

echo "Disabling UE services"
systemctl disable --now ue iperf_client
