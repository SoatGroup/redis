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
7937:C 27 Apr 11:10:52.780 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
7937:M 27 Apr 11:10:52.783 # You requested maxclients of 10000 requiring at least 10032 max file descriptors.
7937:M 27 Apr 11:10:52.783 # Server can't set maximum open files to 10032 because of OS error: Operation not permitted.
7937:M 27 Apr 11:10:52.783 # Current maximum open files is 4096. maxclients has been reduced to 4064 to compensate for low ulimit. If you need higher maxclients increase 'ulimit -n'.
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.2.0 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 7937
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               


... more logs ...
```

## Playing with redis
Using redis-cli, connect to the server instance we just launched.
```shell
$ redis-cli                                                                
redis 127.0.0.1:6379> ping
PONG
redis 127.0.0.1:6379> set mykey somevalue
OK
redis 127.0.0.1:6379> get mykey
"somevalue"
```

