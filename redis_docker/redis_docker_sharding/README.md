# Redis sharding with "REDIS CLUSTER"
Not well supported when executing on a more than one physical servers.

## Prerequisite

Install [Docker][4] and [Docker Compose][3] 

If you are using Windows, please execute the following command before "git clone" to disable changing the line endings of script files into DOS format

```shell
git config --global core.autocrlf false
```

## Docker Compose template of Redis Replication

The tempalte defines the topology of nodes

```shell
master:
  image: mccstanmbg/redis-cluster
slave:
  image: mccstanmbg/redis-cluster
  links:
    - master:redis-master
```

There are following services in this orchestration scenario

* master: Redis master
* slave:  Redis slave


## Play with it

### Build the images

```shell
$ docker-compose build
```

### Start the redis master and slave nodes

```
$ docker-compose-p rs up -d
```

### Check the status of redis cluster

```
$ docker-compose -p rs ps
Name         Command                          State           Ports        
--------------------------------------------------------------------------------------
master_1     docker-entrypoint.sh redis ...   Up              6379/tcp            
slave_1      docker-entrypoint.sh redis ...   Up              6379/tcp    
```

### Instances number and replicas number
If you want `m master` nodes with `n replicas`, you have to:
* Scale out the master nodes to match your needs (*m*)
* Compute the number slaves nodes needed for the replicas number n : let us call this s
  - s = m*n
* Scale out the slaves nodes to match the computed *s*

### Scale out the master instances

```shell
$ docker-compose scale master=3
```

### Scale out the slaves instances

```shell
$ docker-compose scale slave=3
```


### Check the status of redis cluster

```shell
$ docker-compose -p rs ps
   Name                  Command               State    Ports   
---------------------------------------------------------------
rs_master_1   docker-entrypoint.sh redis ...   Up      6379/tcp 
rs_master_2   docker-entrypoint.sh redis ...   Up      6379/tcp 
rs_master_3   docker-entrypoint.sh redis ...   Up      6379/tcp 
rs_slave_1    docker-entrypoint.sh redis ...   Up      6379/tcp 
rs_slave_2    docker-entrypoint.sh redis ...   Up      6379/tcp 
rs_slave_3    docker-entrypoint.sh redis ...   Up      6379/tcp   
```

### Display the project "rs" nodes ip 
```shell
$ docker inspect -f '{{.NetworkSettings.IPAddress }}{{":6379"}} ' $(docker ps -aq --filter "name=rs*")
```

### Display master nodes ip 
```shell
$ docker inspect -f '{{.NetworkSettings.IPAddress }}{{":6379"}} ' $(docker ps -aq --filter "name=master*")
```

### Display the slave nodes ip 
```shell
$ docker inspect -f '{{.NetworkSettings.IPAddress }}{{":6379"}} ' $(docker ps -aq --filter "name=slaves*")
```


### Create the redis cluster using redis-trib
```shell
$REDIS_TRIB create --replicas 1 \
$( docker inspect -f '{{.NetworkSettings.IPAddress }}{{":6379"}}' $(docker ps -aq --filter "name=master*") ) \
$( docker inspect -f '{{.NetworkSettings.IPAddress }}{{":6379"}}' $(docker ps -aq --filter "name=slaves*") )
```

### Redis cluster done
```shell
>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
172.17.0.4:6379
172.17.0.5:6379
172.17.0.2:6379
Adding replica 172.17.0.7:6379 to 172.17.0.4:6379
Adding replica 172.17.0.6:6379 to 172.17.0.5:6379
Adding replica 172.17.0.3:6379 to 172.17.0.2:6379
M: 8d6ce0edccbd78c5459967bcee49764712abd5ee 172.17.0.4:6379
   slots:0-5460 (5461 slots) master
M: 853cccb7fdc956b21acaea08c9e2737bec493d12 172.17.0.5:6379
   slots:5461-10922 (5462 slots) master
M: b071623bf748960ce42d038d9d3ec7f09b708d40 172.17.0.2:6379
   slots:10923-16383 (5461 slots) master
S: 17876e3b72d319e8dd981ca2ecd4b3ff388fbc24 172.17.0.7:6379
   replicates 8d6ce0edccbd78c5459967bcee49764712abd5ee
S: fc1bd96b07fa77b8c6419444c45ca8ccb641eb7d 172.17.0.6:6379
   replicates 853cccb7fdc956b21acaea08c9e2737bec493d12
S: 458584bec69fb7d758774320000a95cf95310605 172.17.0.3:6379
   replicates b071623bf748960ce42d038d9d3ec7f09b708d40
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join...
>>> Performing Cluster Check (using node 172.17.0.4:6379)
M: 8d6ce0edccbd78c5459967bcee49764712abd5ee 172.17.0.4:6379
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: 853cccb7fdc956b21acaea08c9e2737bec493d12 172.17.0.5:6379
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
S: 458584bec69fb7d758774320000a95cf95310605 172.17.0.3:6379
   slots: (0 slots) slave
   replicates b071623bf748960ce42d038d9d3ec7f09b708d40
S: fc1bd96b07fa77b8c6419444c45ca8ccb641eb7d 172.17.0.6:6379
   slots: (0 slots) slave
   replicates 853cccb7fdc956b21acaea08c9e2737bec493d12
M: b071623bf748960ce42d038d9d3ec7f09b708d40 172.17.0.2:6379
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: 17876e3b72d319e8dd981ca2ecd4b3ff388fbc24 172.17.0.7:6379
   slots: (0 slots) slave
   replicates 8d6ce0edccbd78c5459967bcee49764712abd5ee
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```