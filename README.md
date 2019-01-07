# redis
<p align="center">
	<a href="https://redis.io/" target="_blank">
	    <img src="Redis_Logo.svg.png">
	</a>
</p>
Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries. Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster. 

## 1. The quick start guide
This is a quick start guide that targets people without prior experience with Redis. This will help you set up redis and run your first redis instance: [Redis quick start](quick_start)

## 2. Master slave replication on redis 
I you have done with the previous section, or you already know about redis but want to do more, we will focus in this section on how to achieve a master slave replication using redis.
We will do that :
* Manually writing our configs and launching instances.
* Using automation scripts to get things more easier.

Come on guys, it is here :  [master_slave_replication](master_slave_replication).

## 3. Hight avalability with redis sentinel
Redis Sentinel provides high availability for Redis. In practical terms this means that using Sentinel you can create a Redis deployment that resists without human intervention to certain kind of failures.
Redis Sentinel also provides other collateral tasks such as monitoring, notifications and acts as a configuration provider for clients.

Let's do it now : [redis_sentinel](redis_sentinel).

## 4. Twemproxy for sharding, coupled with sentinel for Hight availability
Twemproxy (pronounced "two-em-proxy"), aka nutcracker is a fast and lightweight proxy for memcached and redis protocol. It was built primarily to reduce the number of connections to the caching servers on the backend. This, together with protocol pipelining and sharding enables you to horizontally scale your distributed caching architecture. 

The guide here : [redis_twemproxy](redis_twemproxy).

## 5. Redis cluster : Sharding and High availability.

The step by step guide : [redis_cluster](redis_cluster).

## 5. Redis inside docker containers

The step by step guide : [redis_docker](redis_docker).
