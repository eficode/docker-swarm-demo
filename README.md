# Docker Swarm Demo 

How to run docker swarm with service routing in 5 minutes locally or in AWS.

## Environment setup
Insecure registry for swarm (if you have one, optional):
* `export REGISTRY="<ip>:5000"`
Select installation type and enter folder:
* Install into [Amazon AWS](https://aws.amazon.com/): `cd aws_installation`
* Install locally with [Virtualbox](https://www.virtualbox.org/): `cd local_installation`

## Installation
* [AWS](aws_installation/README.md)
* [Local](local_installation/README.md)

**AWS Settings (if you wish to use aws):**
1. Make a config: `cp configure_aws.template configure_aws.sh`
2. Edit the config
3. Set permissions: `chmod 744 configure_aws.sh`
4. Activate the config: `source configure_aws.sh`
5. The installation creates `docker-machine` security group. Edit permissions to allow all traffic.

## Create Cluster
* **AWS:** `./aws_swarm_up.sh`
* **Local:** `./local_swarm_up.sh`

## Verify installation
**Activate Cluster:**
* AWS: `eval $(docker-machine env --swarm aws-swarm-master)`
* Local: `eval $(docker-machine env --swarm local-swarm-master)`

**Run test app:** 
AWS:
* `docker-compose -f aws-interlock-compose.yml up -d app`
* See Interlock edge-routing logs: `docker-compose -f aws-interlock-compose.yml logs`
* Scale test app: `docker-compose -f aws-interlock-compose.yml scale app=4`  
Local:  
* `docker-compose -f local-interlock-compose.yml up -d app`
* See Interlock edge-routing logs: `docker-compose -f local-interlock-compose.yml logs`
* Scale test app: `docker-compose -f local-interlock-compose.yml scale app=4`


**Accessing:**  
Get interlock ip:  
* AWS: `docker-machine ip aws-swarm-master`
* Local: `docker-machine ip local-swarm-master`  
Add line to `/etc/hosts`:  
    `<ip> test.local`  
Access test app with browser at `test.local`

## Delete Cluster
* AWS: `./aws_swarm_down.sh`
* Local: `./local_swarm_down.sh`


