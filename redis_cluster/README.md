# Redis sharding and high availability with redis cluster

## Things to know about redis cluster
### Redis Cluster data sharding
Redis Cluster does not use consistent hashing, but a different form of sharding where every key is conceptually part of what we call an `hash slot`.
There are `16384` hash slots in Redis Cluster, and to compute what is the hash slot of a given key, we simply take the `CRC16 of the key modulo 16384`.
Every node in a Redis Cluster is responsible for `a subset of the hash slots`, so for example you may have a cluster with 3 nodes, where:
* Node A contains hash slots from `0 to 5500`.
* Node B contains hash slots from `5501 to 11000`.
* Node C contains hash slots from `11001 to 16383`.

### hash tags
Redis Cluster supports multiple key operations as long as all the keys involved into a single command execution (or whole transaction, or Lua script execution) all belong to the same hash slot. The user can force `multiple keys to be part of the same hash slot` by using a concept called `hash tags`.
Considering the key *leftOfBrackets`{`insideBrackets`}`rightOf_Brackets*, only the substring `insideBrackets` will be considered when when computing hash slots.
For instance `this{foo}key` and `another{foo}key` are guaranteed to be in the same hash slot, and can be used together in a command with multiple keys as arguments.

## Prerequies
You should have installation folder into your environment variable PATH, or simply export the `installation folder`/src as a new variable.
We will use the redis-trib.rb ruby script, so you need to create an environment  variable `$REDIS_TRIB` inside your ~/.bashrc pointing to the redis_trib.rb file or simply copy it to tthe current folder. 
You should install ruby and gems for redis
```shell
$ sudo yum install ruby #for Cent os,  sudo apt-get install ruby on Ubuntu or debian - sudo dnf install ruby on fedora
$ gem install redis
```


## Create nodes configurations
Note that the minimal cluster that works as expected requires to contain at least three master nodes. For your first tests it is strongly suggested to start a six nodes cluster with three masters and three slaves.
To do so, enter a new directory, and create the following directories named after the port number of the instance we'll run inside any given directory.
Something like:

### Folders
```shell
$ mkdir redis_cluster # if not already created
$ cd redis_cluster
$ mkdir 7000 7001 7002 7003 7004 7005
```
### Config files
Do the same for the other nodes.
```shell
$ cat > 7000/redis.conf <<EOF
port 7000
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
EOF
```

## Launch the cluster manually
### Run the nodes instances
Do the same for the other nodes
```shell
$ cd 7000
$ redis-server ./redis.conf
```
### Create the cluster using redis-trib
Use the redis-trib create command with a replication factor of 1, Every master should have 3 slaves.
If you created the environment variable $REDIS_TRIB, use the following command, instead copy the redis-trib.rb script inside the current folder and replace the variable with ./redis-trib.rb.
```shell
$ $REDIS_TRIB create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
127.0.0.1:7000
127.0.0.1:7001
127.0.0.1:7002
Adding replica 127.0.0.1:7003 to 127.0.0.1:7000
Adding replica 127.0.0.1:7004 to 127.0.0.1:7001
Adding replica 127.0.0.1:7005 to 127.0.0.1:7002
M: 36405fa912ec3454ed2537184d192b63240aaa38 127.0.0.1:7000
   slots:0-5460 (5461 slots) master
M: fc6bf57baaf93fd3640a4c4ee06f7c74a7fe6f5b 127.0.0.1:7001
   slots:5461-10922 (5462 slots) master
M: db202a44903604319d9308cb8a40eaa7dd08b40a 127.0.0.1:7002
   slots:10923-16383 (5461 slots) master
S: 4c48c79cd99c81214e9da2e01b421912a8175798 127.0.0.1:7003
   replicates 36405fa912ec3454ed2537184d192b63240aaa38
S: 1e14dcb39f83c53b4af3de20378a9d2d932668ad 127.0.0.1:7004
   replicates fc6bf57baaf93fd3640a4c4ee06f7c74a7fe6f5b
S: f54ea962a62451e9a8765c8e95ca027f10270ff7 127.0.0.1:7005
   replicates db202a44903604319d9308cb8a40eaa7dd08b40a
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join...
>>> Performing Cluster Check (using node 127.0.0.1:7000)
M: 36405fa912ec3454ed2537184d192b63240aaa38 127.0.0.1:7000
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: fc6bf57baaf93fd3640a4c4ee06f7c74a7fe6f5b 127.0.0.1:7001
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
M: db202a44903604319d9308cb8a40eaa7dd08b40a 127.0.0.1:7002
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: 1e14dcb39f83c53b4af3de20378a9d2d932668ad 127.0.0.1:7004
   slots: (0 slots) slave
   replicates fc6bf57baaf93fd3640a4c4ee06f7c74a7fe6f5b
S: 4c48c79cd99c81214e9da2e01b421912a8175798 127.0.0.1:7003
   slots: (0 slots) slave
   replicates 36405fa912ec3454ed2537184d192b63240aaa38
S: f54ea962a62451e9a8765c8e95ca027f10270ff7 127.0.0.1:7005
   slots: (0 slots) slave
   replicates db202a44903604319d9308cb8a40eaa7dd08b40a
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

## Launch the cluster with provided scripts without any configuration
TO BE DOCUMENTED SOON.


## play with the cluster
### display the nodes
```shell
$ redis-cli -p 7000 cluster nodes
944ae8c89a1d3dabccf2ff38981f87860ec02c70 127.0.0.1:7003 slave 76bdf24d2cb3e872971d8b4ada473e89185ba10e 0 1491405971762 4 connected
76bdf24d2cb3e872971d8b4ada473e89185ba10e 127.0.0.1:7000 myself,master - 0 0 1 connected 0-5460
faa286d72d916703333dd43b0b79ba048f75f0fc 127.0.0.1:7005 slave 8f92654b63dd33ffe20e116c77fa917e168337a6 0 1491405972263 6 connected
e2d3fcada71380a8cd0f54ad8886c70b929f26f3 127.0.0.1:7004 slave 58fdceb8254d9300f8593a768e222f5f13d7810a 0 1491405970262 5 connected
8f92654b63dd33ffe20e116c77fa917e168337a6 127.0.0.1:7002 master - 0 1491405971261 3 connected 10923-16383
58fdceb8254d9300f8593a768e222f5f13d7810a 127.0.0.1:7001 master - 0 1491405970761 2 connected 5461-10922
```

### display the master nodes
```shell
$ redis-cli -p 7000 cluster nodes | grep master
76bdf24d2cb3e872971d8b4ada473e89185ba10e 127.0.0.1:7000 myself,master - 0 0 1 connected 0-5460
8f92654b63dd33ffe20e116c77fa917e168337a6 127.0.0.1:7002 master - 0 1491406022856 3 connected 10923-16383
58fdceb8254d9300f8593a768e222f5f13d7810a 127.0.0.1:7001 master - 0 1491406022856 2 connected 5461-10922

```

### display the slave nodes
```shell
$ redis-cli -p 7000 cluster nodes | grep slave
944ae8c89a1d3dabccf2ff38981f87860ec02c70 127.0.0.1:7003 slave 76bdf24d2cb3e872971d8b4ada473e89185ba10e 0 1491406060935 4 connected
faa286d72d916703333dd43b0b79ba048f75f0fc 127.0.0.1:7005 slave 8f92654b63dd33ffe20e116c77fa917e168337a6 0 1491406060433 6 connected
e2d3fcada71380a8cd0f54ad8886c70b929f26f3 127.0.0.1:7004 slave 58fdceb8254d9300f8593a768e222f5f13d7810a 0 1491406059931 5 connected
```

### Add a node as master
```shell
$ $REDIS_TRIBb add-node 127.0.0.1:7006 127.0.0.1:7000
```

### Add a node as a slave
```shell
$ $REDIS_TRIBb add-node --slave 127.0.0.1:7006 127.0.0.1:7000

```

### Resharding keys
```shell
$ $REDIS_TRIBb reshard --from <node-id> --to <node-id> --slots <number of slots> --yes <host>:<port>

```

### Display hash slots assignation
```shell
$ redis-cli -p 7000  cluster slots
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "127.0.0.1"
      2) (integer) 7000
      3) "76bdf24d2cb3e872971d8b4ada473e89185ba10e"
   4) 1) "127.0.0.1"
      2) (integer) 7003
      3) "944ae8c89a1d3dabccf2ff38981f87860ec02c70"
2) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "127.0.0.1"
      2) (integer) 7002
      3) "8f92654b63dd33ffe20e116c77fa917e168337a6"
   4) 1) "127.0.0.1"
      2) (integer) 7005
      3) "faa286d72d916703333dd43b0b79ba048f75f0fc"
3) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "127.0.0.1"
      2) (integer) 7001
      3) "58fdceb8254d9300f8593a768e222f5f13d7810a"
   4) 1) "127.0.0.1"
      2) (integer) 7004
      3) "e2d3fcada71380a8cd0f54ad8886c70b929f26f3"
```



### Failover

#### Lauching a simple example that add keys and values. 
```shell
$ cd examples
$ ruby example.rb 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19

```
#### Keys on the master 127.0.0.1:7000
```shell
$ redis-cli -p 7000
127.0.0.1:7000> keys *
   1) "foo554"
   2) "foo4285"
   3) "foo1237"
   4) "foo1727"
   5) "foo536"
   6) "foo291"
   7) "foo1092"
   8) "foo1519"
   9) "foo3108"
  10) "foo2000"
  11) "foo2771"
  12) "foo2573"
  13) "foo2169"
  14) "foo1063"
  15) "foo160"
  16) "foo3498"
  17) "foo1080"
  18) "foo836"
  19) "foo4095"
  20) "foo3772"
  21) "foo908"
  22) "foo2614"
  23) "foo3644"
  24) "foo1243"
  25) "foo1155"

```

#### Get some values from 127.0.0.1:7000
```shell
$ redis-cli -p 7000
127.0.0.1:7000> get foo554
"554"
127.0.0.1:7000> get foo3772
"3772"
127.0.0.1:7000> get foo836
"836"

```

#### Crash a master
Let's start a manual failover to test how the cluster manages the problem.
For this purpose, we will crush the node 127.0.0.1:7000
```shell
$ redis-cli -p 7000 debug segfault
Error: Server closed the connection

```

#### Cluster new state
The node 127.0.0.1:7000 crushed and we could its fail state using another master.
The slave of this node was promoted as master
```shell
$ redis-cli -p 7001 cluster nodes
faa286d72d916703333dd43b0b79ba048f75f0fc 127.0.0.1:7005 slave 8f92654b63dd33ffe20e116c77fa917e168337a6 0 1491468885514 6 connected
76bdf24d2cb3e872971d8b4ada473e89185ba10e 127.0.0.1:7000 master,fail - 1491468869664 1491468868463 10 disconnected
e2d3fcada71380a8cd0f54ad8886c70b929f26f3 127.0.0.1:7004 slave 58fdceb8254d9300f8593a768e222f5f13d7810a 0 1491468886015 5 connected
8f92654b63dd33ffe20e116c77fa917e168337a6 127.0.0.1:7002 master - 0 1491468885012 3 connected 10923-16383
58fdceb8254d9300f8593a768e222f5f13d7810a 127.0.0.1:7001 myself,master - 0 0 2 connected 5461-10922
944ae8c89a1d3dabccf2ff38981f87860ec02c70 127.0.0.1:7003 master - 0 1491468886518 11 connected 0-5460

```

#### Get again the values from previous keys now on the new promoted master `127.0.0.1:7003`

```shell
$ redis-cli -p 7003
127.0.0.1:7003> get foo554
"554"
127.0.0.1:7003> get foo3772
"3772"
127.0.0.1:7003> get foo836
"836"
```

#### Restart the crashed node
If we restart the crashed node, it will automatically join the cluster as a slave of the new promoted master.

```shell
$ redis-cli -p 7000 cluster nodes
8f92654b63dd33ffe20e116c77fa917e168337a6 127.0.0.1:7002 master - 0 1491469315543 3 connected 10923-16383
faa286d72d916703333dd43b0b79ba048f75f0fc 127.0.0.1:7005 slave 8f92654b63dd33ffe20e116c77fa917e168337a6 0 1491469314540 6 connected
944ae8c89a1d3dabccf2ff38981f87860ec02c70 127.0.0.1:7003 master - 0 1491469315041 11 connected 0-5460
58fdceb8254d9300f8593a768e222f5f13d7810a 127.0.0.1:7001 master - 0 1491469315543 2 connected 5461-10922
76bdf24d2cb3e872971d8b4ada473e89185ba10e 127.0.0.1:7000 myself,slave 944ae8c89a1d3dabccf2ff38981f87860ec02c70 0 0 10 connected
e2d3fcada71380a8cd0f54ad8886c70b929f26f3 127.0.0.1:7004 slave 58fdceb8254d9300f8593a768e222f5f13d7810a 0 1491469314540 5 connected

```

#### Check the new key slots repartition scheme

```shell
$ redis-cli -p 7000  cluster slots
1) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "127.0.0.1"
      2) (integer) 7002
      3) "8f92654b63dd33ffe20e116c77fa917e168337a6"
   4) 1) "127.0.0.1"
      2) (integer) 7005
      3) "faa286d72d916703333dd43b0b79ba048f75f0fc"
2) 1) (integer) 0
   2) (integer) 5460
   3) 1) "127.0.0.1"
      2) (integer) 7003
      3) "944ae8c89a1d3dabccf2ff38981f87860ec02c70"
   4) 1) "127.0.0.1"
      2) (integer) 7000
      3) "76bdf24d2cb3e872971d8b4ada473e89185ba10e"
3) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "127.0.0.1"
      2) (integer) 7001
      3) "58fdceb8254d9300f8593a768e222f5f13d7810a"
   4) 1) "127.0.0.1"
      2) (integer) 7004
      3) "e2d3fcada71380a8cd0f54ad8886c70b929f26f3"
```



### Consistency test
A ruby script provided in the examples folder help perform a consistency check on our cluster.

#### Redis cluster still available when performing a failover
Notice that the example we ran is still running.
```shell
$ ruby example.rb 
1
2
3
4
5
...
...
19267
19268
19269
19270
19271
19272

```

#### Launch the consistency test
The consistency-test.rb script in example will do the job. The script will chech writes and reads on the cluster looking for some errors.
There is no error reported here.
```shell
$ ruby consistency-test.rb 127.0.0.1 7000
576 R (0 err) | 576 W (0 err) | 
4858 R (0 err) | 4858 W (0 err) | 
9200 R (0 err) | 9200 W (0 err) | 
13509 R (0 err) | 13509 W (0 err) | 
17776 R (0 err) | 17776 W (0 err) | 
22043 R (0 err) | 22043 W (0 err) | 
26250 R (0 err) | 26250 W (0 err) | 
30488 R (0 err) | 30488 W (0 err) | 
34673 R (0 err) | 34673 W (0 err) | 
38798 R (0 err) | 38798 W (0 err) | 
42362 R (0 err) | 42362 W (0 err) | 
46502 R (0 err) | 46502 W (0 err) | 
50243 R (0 err) | 50243 W (0 err) | 
54409 R (0 err) | 54409 W (0 err) | 
58156 R (0 err) | 58156 W (0 err) | 
61686 R (0 err) | 61686 W (0 err) | 
65389 R (0 err) | 65389 W (0 err) | 
69119 R (0 err) | 69119 W (0 err) | 
73218 R (0 err) | 73218 W (0 err) | 
77383 R (0 err) | 77383 W (0 err) | 
81441 R (0 err) | 81441 W (0 err) | 
84851 R (0 err) | 84851 W (0 err) | 
88595 R (0 err) | 88595 W (0 err) | 
92531 R (0 err) | 92531 W (0 err) | 
96655 R (0 err) | 96655 W (0 err) | 
...

```

#### Crash a node and check again
Let's crash the master on port 7003
```shell
$ redis-cli -p 7003 debug segfault
Error: Server closed the connection

```
### Consistency check resuslts
We could see that there is a lot of errors, becauses some slots moved to maintain the cluster available.
```shell
[mccstan@bmgs-soat examples]$ ruby consistency-test.rb 127.0.0.1 7000
1448 R (0 err) | 1448 W (0 err) | 
5779 R (0 err) | 5779 W (0 err) | 
10007 R (0 err) | 10007 W (0 err) | 
14286 R (0 err) | 14286 W (0 err) | 
18714 R (0 err) | 18714 W (0 err) | 
23079 R (0 err) | 23079 W (0 err) | 
27493 R (0 err) | 27493 W (0 err) | 
Reading: Connection lost (ECONNRESET)
Writing: Too many Cluster redirections? (last error: MOVED 1213 127.0.0.1:7003)
29915 R (1 err) | 29915 W (1 err) | 
Reading: Too many Cluster redirections? (last error: MOVED 2177 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 2177 127.0.0.1:7003)
29919 R (2 err) | 29919 W (2 err) | 
Reading: Too many Cluster redirections? (last error: MOVED 131 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 131 127.0.0.1:7003)
Reading: Too many Cluster redirections? (last error: MOVED 1767 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 1767 127.0.0.1:7003)
29921 R (4 err) | 29921 W (4 err) | 
Reading: Too many Cluster redirections? (last error: MOVED 1929 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 1929 127.0.0.1:7003)
29925 R (5 err) | 29925 W (5 err) | 
Reading: Too many Cluster redirections? (last error: MOVED 1030 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 1030 127.0.0.1:7003)
29927 R (6 err) | 29927 W (6 err) | 
Reading: Too many Cluster redirections? (last error: MOVED 2446 127.0.0.1:7003)
Writing: Too many Cluster redirections? (last error: MOVED 2446 127.0.0.1:7003)
29931 R (7 err) | 29931 W (7 err) | 
Reading: CLUSTERDOWN The cluster is down
Writing: CLUSTERDOWN The cluster is down*
...
...
 
21515 R (0 err) | 21515 W (0 err) | 
26127 R (0 err) | 26127 W (0 err) | 
30671 R (0 err) | 30671 W (0 err) | 
35220 R (0 err) | 35220 W (0 err) | 
39809 R (0 err) | 39809 W (0 err) | 
42396 R (0 err) | 42396 W (0 err) | 
43748 R (0 err) | 43748 W (0 err) | 
46178 R (0 err) | 46178 W (0 err) | 
50700 R (0 err) | 50700 W (0 err) | 

```

### Read data from slaves
To read data from slaves, you nee to be in READONLY mode.
#### Display slave nodes
```shell
$ redis-cli -p 7000 cluster nodes | grep slave
faa286d72d916703333dd43b0b79ba048f75f0fc 127.0.0.1:7005 slave 8f92654b63dd33ffe20e116c77fa917e168337a6 0 1491471469198 6 connected
944ae8c89a1d3dabccf2ff38981f87860ec02c70 127.0.0.1:7003 slave 76bdf24d2cb3e872971d8b4ada473e89185ba10e 0 1491471469699 13 connected
e2d3fcada71380a8cd0f54ad8886c70b929f26f3 127.0.0.1:7004 slave 58fdceb8254d9300f8593a768e222f5f13d7810a 0 1491471469198 5 connected

```

#### Connect to a slave and read stale data
```shell
$ redis-cli -p 7003
127.0.0.1:7003> keys *
...
20834) "31044|321450|12892800|key_981"
20835) "30386|870862|4972100|key_1"
20836) "30425|663672|10214980|key_8745"
20837) "31044|321450|12892800|key_9597"
20838) "31143|389028|10755820|key_4774"
20839) "31143|389028|10755820|key_912"
20840) "foo30709"
20841) "foo18796"
20842) "foo8390"
20843) "foo33735"
...
127.0.0.1:7003> get foo33735
(error) MOVED 3479 127.0.0.1:7000
127.0.0.1:7003> READONLY
OK
127.0.0.1:7003> get foo33735
"33735"

```

