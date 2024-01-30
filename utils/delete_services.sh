#!/bin/bash


systemctl disable --now start_network.service
echo "Disabling BS+Core services"
systemctl disable --now core_network.service
docker rm -f $(docker ps -qa)
systemctl disable --now gnb.service
systemctl disable --now iperf_server
systemclt disable --now xapp_server
systemctl disable --now xapp_client
echo "Disabling UE services"
