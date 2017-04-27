# Slides Replication on redis ❯ https://drive.google.com/open?id=1_btew2TDnmj3zB6NzY7uKtPkFiwdDagab3pe8vg5QL4
<p align="center">
	<a href="https://drive.google.com/open?id=1_btew2TDnmj3zB6NzY7uKtPkFiwdDagab3pe8vg5QL4" target="_blank">
	    <img src="">
	</a>
</p>

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

# Create using the provided script

## Launching redis instances
Here I created a simple script helping you to create config and launch your nodes easily : 
http://gitlab.soat.fr/maturin.bado/cache-redis/blob/4d080bd54d952aa146b600ce64ecd2d4721b6c39/master_slave_replication/master_slaves.sh
### master_slave.sh script
```shell
#!/bin/bash

PORT=6379
ENDPORT=6383
MASTER=0
MASTER_PORT=6380

if [ "$1" == "init" ]
then
    while [ $((PORT < ENDPORT)) != "0" ]; do
        PORT=$((PORT+1))
        MASTER=$((MASTER+1))
        echo "Creating configuration  $PORT"
        mkdir $PORT
        if [ "$MASTER" == 1 ]
        then
            echo -e "port $PORT \ncluster-enabled no \ncluster-config-file nodes.conf \ncluster-node-timeout 5000 \nappendonly yes" >> $PORT/redis.conf
        else
            echo -e "port $PORT \nslaveof 127.0.0.1 $MASTER_PORT \ncluster-enabled no \ncluster-config-file nodes.conf \ncluster-node-timeout 5000 \nappendonly yes" >> $PORT/redis.conf
        fi
    done
    exit 0
fi

if [ "$1" == "start" ]
then
    while [ $((PORT < ENDPORT)) != "0" ]; do
        PORT=$((PORT+1))
        echo "Starting $PORT"
        redis-server $PORT/redis.conf --daemonize yes
    done
    exit 0
fi

if [ "$1" == "stop" ]
then
    while [ $((PORT < ENDPORT)) != "0" ]; do
        PORT=$((PORT+1))
        echo "Stopping $PORT"
        redis-cli -p $PORT shutdown nosave
    done
    exit 0
fi

```

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
redis-cli
```shell
redis-cli -p 6380

```
info
```shell
127.0.0.1:6380> 
[mccstan@bmgs-soat redis-3.2.8]$ redis-cli -p 6380
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
run_id:0833eb18f8887bd624ba293c4a8706831f8469b9
tcp_port:6380
uptime_in_seconds:1811
uptime_in_days:0
hz:10
lru_clock:14578568
executable:/home/mccstan/my_tools/redis-3.2.8/cluster-test/7000/test_ok/redis-server
config_file:/home/mccstan/my_tools/redis-3.2.8/cluster-test/7000/test_ok/6380/redis.conf

# Clients
connected_clients:2
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Memory
used_memory:1719416
used_memory_human:1.64M
used_memory_rss:10014720
used_memory_rss_human:9.55M
used_memory_peak:1800008
used_memory_peak_human:1.72M
total_system_memory:8124719104
total_system_memory_human:7.57G
used_memory_lua:37888
used_memory_lua_human:37.00K
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
mem_fragmentation_ratio:5.82
mem_allocator:jemalloc-4.0.3

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1490971765
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:0
rdb_current_bgsave_time_sec:-1
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_current_size:0
aof_base_size:0
aof_pending_rewrite:0
aof_buffer_length:0
aof_rewrite_buffer_length:0
aof_pending_bio_fsync:0
aof_delayed_fsync:0

# Stats
total_connections_received:6
total_commands_processed:5525
instantaneous_ops_per_sec:1
total_net_input_bytes:200543
total_net_output_bytes:162433
instantaneous_input_kbps:0.07
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:3
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:214
migrate_cached_sockets:0

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

# CPU
used_cpu_sys:0.99
used_cpu_user:0.69
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Cluster
cluster_enabled:0

# Keyspace

```



### Stop instances
```shell
./master_slave stop

```


