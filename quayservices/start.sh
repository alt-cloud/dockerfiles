#!/bin/sh

Stack=SERVICE_QUAY_REG

docker-compose config > docker-swarm.yml
docker stack  deploy -c docker-swarm.yml $Stack

# docker-compose  -p QUAY up -d
