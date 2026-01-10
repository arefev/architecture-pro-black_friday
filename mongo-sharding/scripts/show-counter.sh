#!/bin/bash

###

echo -e "\n---Количество элементов в shard1---\n";
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

echo -e "\n\n---Количество элементов в shard2---\n";
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF