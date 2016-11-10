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

if [ -z "$AMI" ]; then
    echo "Please set AMI to continue" 1>&2
    exit 1
elif [ -z "$KEYPATH" ]; then
    echo "Please set KEYPATH to continue" 1>&2
    exit 1
elif [ -z "$VPC_ID" ]; then
    echo "Please set VPC_ID to continue" 1>&2
    exit 1
elif [ -z "$SUBNET_ID" ]; then
    echo "Please set SUBNET_ID to continue" 1>&2
    exit 1
elif [ -z "$DISK" ]; then
    echo "Please set DISK to continue" 1>&2
    exit 1
elif [ -z "$REGION" ]; then
    echo "Please set REGION to continue" 1>&2
    exit 1
elif [ -z "$KEYSTORE_TYPE" ]; then
    echo "Please set KEYSTORE_TYPE to continue" 1>&2
    exit 1
elif [ -z "$MASTER_TYPE" ]; then
    echo "Please set MASTER_TYPE to continue" 1>&2
    exit 1
elif [ -z "$NODE_TYPE" ]; then
    echo "Please set NODE_TYPE to continue" 1>&2
    exit 1
fi

docker-machine create \
    --driver amazonec2 \
    --amazonec2-ami $AMI \
    --amazonec2-instance-type $KEYSTORE_TYPE \
    --amazonec2-vpc-id $VPC_ID \
    --amazonec2-region $REGION \
    --amazonec2-subnet-id $SUBNET_ID \
    --amazonec2-root-size $DISK \
    --amazonec2-ssh-keypath $KEYPATH \
    aws-swarm-keystore

docker $(docker-machine config aws-swarm-keystore) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

docker-machine create \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip aws-swarm-keystore):8500" \
    --engine-opt "cluster-store=consul://$(docker-machine ip aws-swarm-keystore):8500" \
    --engine-opt "cluster-advertise=eth0:2376" \
    $REGISTRY \
    --driver amazonec2 \
    --amazonec2-ami $AMI \
    --amazonec2-instance-type $MASTER_TYPE \
    --amazonec2-vpc-id $VPC_ID \
    --amazonec2-region $REGION \
    --amazonec2-subnet-id $SUBNET_ID \
    --amazonec2-root-size $DISK \
    --amazonec2-ssh-keypath $KEYPATH \
    aws-swarm-master

for i in `seq 1 2`; do
    docker-machine create \
        --swarm \
        --swarm-discovery="consul://$(docker-machine ip aws-swarm-keystore):8500" \
        --engine-opt="cluster-store=consul://$(docker-machine ip aws-swarm-keystore):8500" \
        --engine-opt="cluster-advertise=eth0:2376" \
        $REGISTRY \
        --driver amazonec2 \
        --amazonec2-ami $AMI \
        --amazonec2-instance-type $NODE_TYPE \
        --amazonec2-vpc-id $VPC_ID \
        --amazonec2-region $REGION \
        --amazonec2-subnet-id $SUBNET_ID \
        --amazonec2-root-size $DISK \
        --amazonec2-ssh-keypath $KEYPATH \
        "aws-swarm-node"$i
done

docker $(docker-machine config aws-swarm-master) network create --driver overlay --subnet=10.13.37.0/24 overlay-net

# Add interlock routing
export SWARM_HOST=tcp://$(docker-machine ip aws-swarm-master):3376
eval $(docker-machine env aws-swarm-master)
docker-compose -f interlock-compose.yml up -d nginx
docker-compose -f interlock-compose.yml up -d interlock

echo "########################"
echo "Your swarm is up and running!"
echo "Run this command to configure your shell:"
echo 'eval $(docker-machine env --swarm aws-swarm-master)'

