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
        cd $PORT
        redis-server ./redis.conf --daemonize yes
        cd ..
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

