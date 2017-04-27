# Get started with redis

## Installation
### Download, extract and compile Redis. You could choose an earlier version.

```shell
wget http://download.redis.io/releases/redis-3.2.8.tar.gz
tar xzf redis-3.2.8.tar.gz
cd redis-3.2.8
make
```

### run redis everywhere
It is a good idea to copy both the Redis server and the command line interface in proper places, either manually using the following commands:
```shell
sudo cp src/redis-server /usr/local/bin/
sudo cp src/redis-cli /usr/local/bin/
```

## Starting Redis
The simplest way to start the Redis server is just executing the redis-server binary without any argument.
```shell
$ redis-server
[28550] 01 Aug 19:29:28 # Warning: no config file specified, using the default config. In order to specify a config file use 'redis-server /path/to/redis.conf'
[28550] 01 Aug 19:29:28 * Server started, Redis version 2.2.12
[28550] 01 Aug 19:29:28 * The server is now ready to accept connections on port 6379
... more logs ...
```

## Playing with redis
Using redis clis, connect to the server instance we just launched.
```shell
$ redis-cli                                                                
redis 127.0.0.1:6379> ping
PONG
redis 127.0.0.1:6379> set mykey somevalue
OK
redis 127.0.0.1:6379> get mykey
"somevalue"
```

