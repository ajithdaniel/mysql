#!/bin/bash
set -x
array=('10.14.1.4' '10.14.1.111' '10.14.26.51' '10.14.26.114' '10.14.1.240' '10.14.64.66' '10.14.65.10' '10.14.64.69' '10.14.64.113')
node_counter=0
length=${#array[@]}
IFS=$'\n'
for line in $(curl -s 'http://127.0.0.1:9200/_cat/shards'|  fgrep UNASSIGNED); do
    INDEX=$(echo $line | (awk '{print $1}'))
    SHARD=$(echo $line | (awk '{print $2}'))
    NODE=${array[$node_counter]}
    echo $NODE
    curl -XPOST 'http://127.0.0.1:9200/_cluster/reroute' -d '{
        "commands": [
        {
            "allocate": {
                "index": "'$INDEX'",
                "shard": '$SHARD',
                "node": "'$NODE'",
                "allow_primary": true
            }
        }
        ]
    }'
    node_counter=$(((node_counter)%length +1))
done
