# Master-Slave Replication with Redis : step by step
If you didn't yet played with redis, then follow this guide to set i up and then come back here.
We assume that you have added the <redisfolder/src folder to tha path environement variable. We will use redis-server and redis-clis from any folder.

## Choose a folder from where to play with redis.
Here we choose redis_replication.
```shell
mkdir redis_replication && cd redis_replication
```

## Create the master and slaves folders and config files
The configuration is quite simple, this will be done by the `redis.conf` file inside folders named by the specific redis instance `port number`. Then set the port number by `port <port number>`, and disable cluster mode by `cluster-enabled no`.

To configure replication is trivial: just add the following line to the slave configuration file:
```shell
slaveof 127.0.0.1 6379
```

### master
```shell
mkdir 6380
cat > 6380/redis.conf <<EOF
port 6380
cluster-enabled no
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```

### slave 1
```shell
mkdir 6381
cat > 6381/redis.conf <<EOF
port 6381
slaveof 127.0.0.1 6380
cluster-enabled no
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```


### slave 2
```shell
mkdir 6382
cat > 6382/redis.conf <<EOF
port 6382
slaveof 127.0.0.1 6380
cluster-enabled no
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```


### slave 3
```shell
mkdir 6383
cat > 6383/redis.conf <<EOF
port 6383
slaveof 127.0.0.1 6380
cluster-enabled no
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```

## Manualy start the instances
Type the following commands in separated shells
### master
```shell
cd 6380
redis-server ./redis.conf
```
### slave 1
```shell
cd 6381
redis-server ./redis.conf
```
### slave 2
```shell
cd 6382
redis-server ./redis.conf
```
### slave 3
```shell
cd 6383
redis-server ./redis.conf
```
### Connect to the master node and play with
redis-cli
```shell
redis-cli -p 6380
```

# Create using the automation script

## Launching redis instances
Here I created a simple script helping you  create config and launch your nodes easily : 
[automation script](master_slave_replication/master_slaves.sh)


### Initialise config files
```shell
chmod +x master_slave.sh
./master_slave init

```

### Start redis instances
```shell
./master_slave start

```


## Connect to the master node and play with
### redis-cli
```shell
redis-cli -p 6380
```

### info
```shell
127.0.0.1:6380> info
# Server
redis_version:3.2.0
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:8d88dc6cfd069418
redis_mode:standalone
os:Linux 3.10.0-514.10.2.el7.x86_64 x86_64
arch_bits:64
multiplexing_api:epoll
gcc_version:4.4.7
process_id:19378

.... more infos .....

# Replication
role:master
connected_slaves:3
slave0:ip=127.0.0.1,port=6381,state=online,offset=2521,lag=0
slave1:ip=127.0.0.1,port=6382,state=online,offset=2521,lag=1
slave2:ip=127.0.0.1,port=6383,state=online,offset=2521,lag=1
master_repl_offset:2521
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:2520

.... more infos .....
```


### Stop instances
```shell
./master_slave stop

```


