#!/bin/bash
#cd /root/oai-cn5g-fed/docker-compose/
#python3 core-network.py --scenario 1 --type start-mini

docker compose -f /root/OAI-Colosseum/core/docker-compose-mini-nrf.yaml down 
docker compose -f /root/OAI-Colosseum/core/docker-compose-mini-nrf.yaml up -d
