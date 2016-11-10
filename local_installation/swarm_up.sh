#!/bin/bash

# Creates a swarm cluster with a keystore + one master and 2 nodes

set -e

if [ -z "$REGISTRY" ]; then
    INSECURE_REGISTRY=""
    echo "No insecure-registry specified"
else
    INSECURE_REGISTRY="--engine-insecure-registry $REGISTRY"
    echo "insecure-registry $REGISTRY"
fi

docker-machine create \
    --driver virtualbox \
    local-swarm-keystore

docker $(docker-machine config local-swarm-keystore) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

docker-machine create \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip local-swarm-keystore):8500" \
    --engine-opt "cluster-store=consul://$(docker-machine ip local-swarm-keystore):8500" \
    --engine-opt "cluster-advertise=eth0:2376" \
    $REGISTRY \
    --driver virtualbox \
    local-swarm-master

for i in `seq 1 2`; do
    docker-machine create \
        --swarm \
        --swarm-discovery="consul://$(docker-machine ip local-swarm-keystore):8500" \
        --engine-opt="cluster-store=consul://$(docker-machine ip local-swarm-keystore):8500" \
        --engine-opt="cluster-advertise=eth0:2376" \
        $REGISTRY \
        --driver virtualbox \
        "local-swarm-node"$i
done

docker $(docker-machine config local-swarm-master) network create --driver overlay --subnet=10.13.37.0/24 overlay-net

# Add interlock routing
export SWARM_HOST=tcp://$(docker-machine ip local-swarm-master):3376
eval $(docker-machine env local-swarm-master)
docker-compose -f interlock-compose.yml up -d nginx
docker-compose -f interlock-compose.yml up -d interlock

echo "########################"
echo "Run this command to configure your shell:"
echo 'eval $(docker-machine env --swarm local-swarm-master)'
