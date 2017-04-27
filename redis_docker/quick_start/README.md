# First steps with redis
## install docker for cent os
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-centos-7
## Dockerfile from github in the file Dockerfile
https://github.com/dockerfile/redis

```shell
#
# Redis Dockerfile
# @mccstanmbg

# Pull base image.
FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

# Expose ports.
EXPOSE 6379
```

## Create a redis config file
```shell
$ cat > redis.conf <<EOF
port 6379
cluster-enabled no
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```

## Build the redis image
```shell
$ sudo docker build -t mccstanmbg/redis .
[sudo] password for mccstan:
Sending build context to Docker daemon  7.68 kB
Step 1/6 : FROM redis
latest: Pulling from library/redis
Digest: sha256:1b358a2b0dc2629af3ed75737e2f07e5b3408eabf76a8fa99606ec0c276a93f8
Status: Downloaded newer image for redis:latest
 ---> 83d6014ac5c8
Step 2/6 : COPY redis.conf /usr/local/etc/redis/redis.conf
 ---> 4d272237ca55
Removing intermediate container 7e002c8fa3f7
Step 3/6 : VOLUME /data
 ---> Running in 107846806bf7
 ---> 5c3e01892291
Removing intermediate container 107846806bf7
Step 4/6 : WORKDIR /data
 ---> fb96891357db
Removing intermediate container 028e823e3a3d
Step 5/6 : CMD redis-server /usr/local/etc/redis/redis.conf
 ---> Running in 1cf15c91f765
 ---> a90692cda88f
Removing intermediate container 1cf15c91f765
Step 6/6 : EXPOSE 6379
 ---> Running in 50f3d4b30bea
 ---> 8812db9c531d
Removing intermediate container 50f3d4b30bea
Successfully built 8812db9c531d

```

## show the images
```shell
$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mccstanmbg/redis    latest              8812db9c531d        5 minutes ago       184 MB
redis               latest              83d6014ac5c8        2 weeks ago         184 MB
hello-world         latest              48b5124b2768        2 months ago        1.84 kB
```

## Tag our new image
```shell
$ docker tag 8812db9c531d mccstanmbg/redis:latest
```

## Login and push the image
```shell
$ sudo docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don t have a Docker ID, head over to https://hub.docker.com to create one.
Username (mccstanmbg):
$ sudo docker push mccstanmbg/redis
The push refers to a repository [docker.io/mccstanmbg/redis]
375bbf60cbd5: Pushed
d628bb04e56f: Pushed
65bfe09e2af0: Pushed
df13bd4aa4fe: Pushed
b3df689d89b7: Pushed
f69752fa3fd5: Pushed
6e137b6d005f: Pushed
5d6cbe0dbcf9: Pushed
latest: digest: sha256:e2ff9a089c29164edc52f74dd0d4aa1a742a1dd20386cc428b108f6a1f2d0654 size: 1990
```


## Start the redis container
```shell
$ sudo docker run --name redis_quick_start -p 6379:6379 -d mccstanmbg/redis
94b22d08526806381e5bcb816cca96195e6873f26f76e90a701ee02b81698517
```
## Connect to the redis instance and play with.
### From outside, using redis-cli
```shell
$ redis-cli -p 6379
127.0.0.1:6379>
```
### OR Using a container link and redis-cli
```shell
$ sudo docker run -it --link redis_quick_start:redis --rm redis redis-cli -h redis -p 6379
redis:6379>
redis:6379> set key value
OK
redis:6379> get key
"value"
redis:6379> set users.ksana "{name:SANA, age:26}"
redis:6379> set users.mccstan "{name:BADO, age:24}"
redis:6379> get users.mccstan
"{name:BADO, age:24}"
redis:6379> get users.ksana
"{name:SANA, age:26}"

```
