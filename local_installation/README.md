## Create Cluster
`./swarm_up.sh`

## Verify installation
Activate Cluster: `eval $(docker-machine env --swarm local-swarm-master)`  
Run test app: `docker-compose -f interlock-compose.yml up -d app`  
See Interlock edge-routing logs: `docker-compose -f interlock-compose.yml logs`  
Scale test app: `docker-compose -f interlock-compose.yml scale app=4`

## Accessing
Get interlock ip: `docker-machine ip local-swarm-master`  
Add line to `/etc/hosts`: `<ip> test.local.swarm.demo`  
Access test app with browser: `http://test.local.swarm.demo/`

## Delete Cluster
`./swarm_down.sh`
