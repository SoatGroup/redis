# Redis replication inside docker containers
## Run the container using custom configuration
```shell
$ docker run -v /mycustomconfig/conf/redis.conf:/usr/local/etc/redis/redis.conf --name myredis redis redis-server /usr/local/etc/redis/redis.conf
```
