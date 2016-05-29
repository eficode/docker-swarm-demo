## Settings
* Configure insecure registry for swarm (if you have one, optional): `export REGISTRY="<ip>:5000"`
* Make a config: `cp configure_aws.template configure_aws.sh`
* Edit values in the config: `vi configure_aws.sh`
* Set permissions: `chmod 744 configure_aws.sh`
* Activate the config: `source configure_aws.sh`

## Create Cluster
`./swarm_up.sh`  
The installation creates `docker-machine` security group. Edit permissions to allow all traffic.

## Verify installation
Activate Cluster: `eval $(docker-machine env --swarm aws-swarm-master)`  
Run test app: `docker-compose -f interlock-compose.yml up -d app`  
See Interlock edge-routing logs: `docker-compose -f interlock-compose.yml logs`  
Scale test app: `docker-compose -f interlock-compose.yml scale app=4`

## Accessing  
Get interlock ip: `docker-machine ip aws-swarm-master`  
Add line to `/etc/hosts`: `<ip> test.aws.swarm.demo`  
Access test app with browser at `http://test.aws.swarm.demo/`

## Delete Cluster
`./swarm_down.sh`
