#
# Redis Dockerfile
# @mccstanmbg
#
#

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
