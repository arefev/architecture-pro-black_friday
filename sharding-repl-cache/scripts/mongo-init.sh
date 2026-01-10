#!/bin/bash

###

echo -e "\n\n---Создание кластера кеширования---\n";
docker compose exec -T redis_1 bash -c "echo \"yes\" | redis-cli --cluster create   173.17.0.2:6379   173.17.0.3:6379   173.17.0.4:6379   173.17.0.5:6379   173.17.0.6:6379   173.17.0.15:6379   --cluster-replicas 1"

echo -e "\n---Инициализация сервера конфигурации---\n";
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

echo -e "\n\n---Инициализация shard1---\n";
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({_id: "shard1", members: [
{_id: 0, host: "shard1:27018"},
{_id: 1, host: "shard1-repl1:27018"},
{_id: 2, host: "shard1-repl2:27018"}
]})
EOF

echo -e "\n\n---Инициализация shard2---\n";
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({_id: "shard2", members: [
{_id: 0, host: "shard2:27019"},
{_id: 1, host: "shard2-repl1:27018"},
{_id: 2, host: "shard2-repl2:27018"}
]})
EOF

echo -e "\n\n---Инициализация роутера---\n";
sleep 3;
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments() 
EOF