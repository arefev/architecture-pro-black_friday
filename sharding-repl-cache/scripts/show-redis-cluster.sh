#!/bin/bash

###

echo -e "\n\n---Redis cluster nodes---\n";
docker compose exec -T redis_1 bash -c "redis-cli cluster nodes"