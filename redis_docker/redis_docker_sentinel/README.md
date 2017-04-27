
# Redis replication inside docker containers

## Prerequisite

Install [Docker][4] and [Docker Compose][3] 

If you are using Windows, please execute the following command before "git clone" to disable changing the line endings of script files into DOS format

```
git config --global core.autocrlf false
```

## Docker Compose template of Redis Replication

The tempalte defines the topology of nodes

```shell
master:
  image: mccstanmbg/redis
slave:
  image: mccstanmbg/redis
  command: redis-server --slaveof redis-master 6379
  links:
    - master:redis-master
sentinel:
  image: mccstanmbg/sentinel
  environment:
    - SENTINEL_DOWN_AFTER=5000
    - SENTINEL_FAILOVER=5000    
  links:
    - master:redis-master
    - slave
```

There are following services in this orchestration topology

* master: Redis master
* slave:  Redis slave
* sentinel: Redis sentinel


The sentinels are configured with a "ha_master" instance group with the following properties -

```
sentinel monitor ha_master redis-master 6379 2
sentinel down-after-milliseconds ha_master 5000
sentinel parallel-syncs ha_master 1
sentinel failover-timeout ha_master 5000
```

The details could be found in sentinel/sentinel.conf

The default values of the environment variables for Sentinel are as following

* SENTINEL_QUORUM: 2
* SENTINEL_DOWN_AFTER: 30000
* SENTINEL_FAILOVER: 180000


## Play with it

### Build the sentinel image

```shell
$ docker-compose build
master uses an image, skipping
slave uses an image, skipping
Building sentinel
Step 1/11 : FROM mccstanmbg/redis
 ---> 8812db9c531d
Step 2/11 : EXPOSE 5000
 ---> Using cache
 ---> c79e28708785
Step 3/11 : ADD sentinel.conf /etc/redis/sentinel.conf
 ---> 97df856fddb1
Removing intermediate container 06c22165edc5
Step 4/11 : RUN chown redis:redis /etc/redis/sentinel.conf
 ---> Running in 68dcda2cf943
 ---> 9d20f7da8eb6
Removing intermediate container 68dcda2cf943
Step 5/11 : ENV SENTINEL_QUORUM 2
 ---> Running in c34e6f5739b0
 ---> 5adc5723cf3f
Removing intermediate container c34e6f5739b0
Step 6/11 : ENV SENTINEL_DOWN_AFTER 30000
 ---> Running in 4a5e707f7e5d
 ---> 36d439ea8a74
Removing intermediate container 4a5e707f7e5d
Step 7/11 : ENV SENTINEL_FAILOVER 180000
 ---> Running in 4bf6ef40d9ec
 ---> d3b6a8ea0f34
Removing intermediate container 4bf6ef40d9ec
Step 8/11 : ENV SENTINEL_MASTER_GROUP "ha_master"
 ---> Running in 057ce86b131d
 ---> bf353ae7076e
Removing intermediate container 057ce86b131d
Step 9/11 : COPY sentinel-entrypoint.sh /usr/local/bin/
 ---> 03f11b6af992
Removing intermediate container 3e646e6f063c
Step 10/11 : RUN chmod +x /usr/local/bin/sentinel-entrypoint.sh
 ---> Running in c182b3817033
 ---> 02958aaa3455
Removing intermediate container c182b3817033
Step 11/11 : ENTRYPOINT sentinel-entrypoint.sh
 ---> Running in be2c6b09ccaa
 ---> 2df5d93ef526
Removing intermediate container be2c6b09ccaa
Successfully built 2df5d93ef526
```

### Start the master, slave and sentinel nodes, let's call the project rs(redis sentinel)

```
$ docker-compose -p rs up -d
Building sentinel
Step 1/11 : FROM mccstanmbg/redis
 ---> 8812db9c531d
Step 2/11 : EXPOSE 5000
 ---> Using cache
 ---> c79e28708785
Step 3/11 : ADD sentinel.conf /etc/redis/sentinel.conf
 ---> Using cache
 ---> 97df856fddb1
Step 4/11 : RUN chown redis:redis /etc/redis/sentinel.conf
 ---> Using cache
 ---> 9d20f7da8eb6
Step 5/11 : ENV SENTINEL_QUORUM 2
 ---> Using cache
 ---> 5adc5723cf3f
Step 6/11 : ENV SENTINEL_DOWN_AFTER 30000
 ---> Using cache
 ---> 36d439ea8a74
Step 7/11 : ENV SENTINEL_FAILOVER 180000
 ---> Using cache
 ---> d3b6a8ea0f34
Step 8/11 : ENV SENTINEL_MASTER_GROUP "ha_master"
 ---> Using cache
 ---> bf353ae7076e
Step 9/11 : COPY sentinel-entrypoint.sh /usr/local/bin/
 ---> Using cache
 ---> 03f11b6af992
Step 10/11 : RUN chmod +x /usr/local/bin/sentinel-entrypoint.sh
 ---> Using cache
 ---> 02958aaa3455
Step 11/11 : ENTRYPOINT sentinel-entrypoint.sh
 ---> Using cache
 ---> 2df5d93ef526
Successfully built 2df5d93ef526
WARNING: Image for service sentinel was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Creating rs_master_1
Creating rs_slave_1
Creating rs_sentinel_1
```

### Check the status of redis cluster

```
$ docker-compose -p rs up -d
Creating rs_master_1
Creating rs_slave_1
Creating rs_sentinel_1
  
```


### Scale out the instance number of sentinels

```shell
$ docker-compose -p rs scale sentinel=3
Creating and starting rs_sentinel_2 ... done
Creating and starting rs_sentinel_3 ... done
```

### Scale out the instance number of slaves you want for your master

```shell
$ docker-compose -p rs scale slave=2
Creating and starting rs_slave_2 ... done
```

### Check the status oof the deplyed nodes

```shell
$ docker-compose -p rs ps
    Name                   Command               State          Ports        
----------------------------------------------------------------------------
rs_master_1     docker-entrypoint.sh redis ...   Up      6379/tcp            
rs_sentinel_1   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp 
rs_sentinel_2   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp 
rs_sentinel_3   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp 
rs_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp            
rs_slave_2      docker-entrypoint.sh redis ...   Up      6379/tcp   
```

## Execute test scripts
to simulate stop and recover the Redis master. And you will see the master is switched to slave automatically. 
```shell
$ ./test.sh
```


Or, you can do the test manually to pause/unpause redis server through

```shell
$ docker pause rs_master_1
$ docker unpause rs_master_1
```
And get the sentinel infomation with following commands

```shell
$ docker exec rs_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name ha_master
```

## References

[1]: https://hub.docker.com/r/mccstanmbg/redis/
[2]: https://github.com/AliyunContainerService/redis-cluster
[3]: https://docs.docker.com/compose/
[4]: https://www.docker.com

## Contributors

* Maturin BADO (<maturinbado@gmail.com>)

