#!/bin/bash

PORT=5000
ENDPORT=5003
MASTER_GROUP_NAME="ha_master"
MASTER_IP="127.0.0.1"
MASTER_PORT="6380"
QUORUM=2
PARALLELE_SYNCHS=1

## comment if you launched the master_slave.sh script to create the nodes.


if [ "$1" == "init" ]
then
    ./master_slave.sh init
    ./master_slave.sh start
    while [ $((PORT < ENDPORT)) != "0" ]; do
        
        MASTER=$((MASTER+1))
        echo "Creating sentinel configuration  $PORT"
        mkdir $PORT
        echo -e "port $PORT \nsentinel monitor $MASTER_GROUP_NAME $MASTER_IP $MASTER_PORT $QUORUM \nsentinel down-after-milliseconds $MASTER_GROUP_NAME 5000 \nsentinel parallel-syncs $MASTER_GROUP_NAME $PARALLELE_SYNCHS \nsentinel failover-timeout $MASTER_GROUP_NAME 60000" >> $PORT/sentinel.conf
        PORT=$((PORT+1))
    done
    exit 0
fi

if [ "$1" == "start" ]
then
    while [ $((PORT < ENDPORT)) != "0" ]; do
        echo "Starting sentinel  $PORT"
        cd $PORT
        redis-server ./sentinel.conf --sentinel --daemonize yes
        cd ..
        PORT=$((PORT+1))
    done
    exit 0
fi

if [ "$1" == "stop" ]
then
    while [ $((PORT < ENDPORT)) != "0" ]; do
        
        echo "Stopping $PORT"
        redis-cli -p $PORT shutdown nosave
        PORT=$((PORT+1))
    done
    exit 0
fi

