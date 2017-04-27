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
$ docker-compose up -d
```

### Check the status of redis cluster

```
$ docker-compose ps
Name         Command                          State           Ports        
--------------------------------------------------------------------------------------
master_1     docker-entrypoint.sh redis ...   Up              6379/tcp            
slave_1      docker-entrypoint.sh redis ...   Up              6379/tcp    
```


### Scale out the instance number of slaves you want for your master

```shell
$ docker-compose scale slave=2
```

### Check the status of redis cluster

```shell
$ docker-compose ps
Name         Command                          State           Ports        
--------------------------------------------------------------------------------------
master_1     docker-entrypoint.sh redis ...   Up              6379/tcp            
slave_1      docker-entrypoint.sh redis ...   Up              6379/tcp
slave_2      docker-entrypoint.sh redis ...   Up              6379/tcp 
slave_3      docker-entrypoint.sh redis ...   Up              6379/tcp     
```

### Get the master information

```shell
$ docker exec master_1 redis-cli -p 6379 info
# Server
redis_version:3.2.8
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:36c619aa94c6572b
redis_mode:standalone
os:Linux 3.10.0-514.10.2.el7.x86_64 x86_64
arch_bits:64
multiplexing_api:epoll
gcc_version:4.9.2
process_id:1
run_id:44c0c4df6ba35c50fa67b66f070ab97eb3117799
tcp_port:6379
uptime_in_seconds:1886
uptime_in_days:0
hz:10
lru_clock:15161785
executable:/data/redis-server
config_file:/usr/local/etc/redis/redis.conf

# Clients
connected_clients:7
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Memory
used_memory:2037688
used_memory_human:1.94M
used_memory_rss:10473472
used_memory_rss_human:9.99M
used_memory_peak:2139656
used_memory_peak_human:2.04M
total_system_memory:8124719104
total_system_memory_human:7.57G
used_memory_lua:37888
used_memory_lua_human:37.00K
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
mem_fragmentation_ratio:5.14
mem_allocator:jemalloc-4.0.3

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1491555156
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
total_connections_received:13
total_commands_processed:11636
instantaneous_ops_per_sec:7
total_net_input_bytes:556802
total_net_output_bytes:2997025
instantaneous_input_kbps:0.37
instantaneous_output_kbps:4.25
rejected_connections:0
sync_full:4
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:1
pubsub_patterns:0
latest_fork_usec:2111
migrate_cached_sockets:0

# Replication
role:master
connected_slaves:2
slave0:ip=172.17.0.3,port=6379,state=online,offset=344275,lag=1
slave1:ip=172.17.0.7,port=6379,state=online,offset=344410,lag=0
master_repl_offset:344680
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:344679

# CPU
used_cpu_sys:2.32
used_cpu_user:1.07
used_cpu_sys_children:0.02
used_cpu_user_children:0.00

# Cluster
cluster_enabled:0

# Keyspace

```
