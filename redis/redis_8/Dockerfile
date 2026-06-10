FROM redis:8
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Copy custom redis configuration if needed
# COPY redis.conf /usr/local/etc/redis/redis.conf

# Use the default redis-server command with custom config
# CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]