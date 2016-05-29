#!/bin/bash

docker-machine rm -f aws-swarm-node2
docker-machine rm -f aws-swarm-node1
docker-machine rm -f aws-swarm-master
docker-machine rm -f aws-swarm-keystore