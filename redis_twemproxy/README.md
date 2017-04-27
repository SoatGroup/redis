# Sharding with twemproxy
<p align="center">
	<a href="https://redis.io/" target="_blank">
	    <img src="twemproxy.png">
	</a>
</p>

## Installation

## Download the distribution tarball
Download here : [twemproxy releases](https://drive.google.com/open?id=0B6pVMMV5F5dfMUdJV25abllhUWM&authuser=0)

## Build
Make sure you have a well configured developpement environment.
Link  
```shell
apt-get install automake
apt-get install libtool
git clone git://github.com/twitter/twemproxy.git
cd twemproxy
autoreconf -fvi
./configure --enable-debug=log
make
src/nutcracker -h
```

Using redis-cli, connect to the server instance we just launched.
```shell
```

