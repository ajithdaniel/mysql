#!/bin/bash
#set -x

server_stat="/tmp/stats_test.log"
table_struc="/tmp/table_struc.txt"
>$table_struc
>$server_stat
>'/tmp/version_check_mysql.txt'
cmd1="sudo su -c"

cmd2="\"mysql -BNe 'SELECT table_name , round(((data_length + index_length + data_free ) / 1024 / 1024 / 1024  ), 2) FROM information_schema.TABLES;' \""
cmd3="\"mysql -BNe 'show create table $2.$3\\G'\""
cmd4="\"mysql -e 'select @@hostname,@@version'\""
cmd5="df -hT"

ssh -t -o ConnectTimeout=3 -o StrictHostKeyChecking=no $1 "$cmd1" "$cmd2"   >$server_stat
ssh  -t -o ConnectTimeout=3 -o StrictHostKeyChecking=no $1 "$cmd1" "$cmd3" > $table_struc
ssh  -t -o ConnectTimeout=3 -o StrictHostKeyChecking=no $1 "$cmd1" "$cmd4"   > '/tmp/version_check_mysql.txt'
ssh  -t -o ConnectTimeout=3 -o StrictHostKeyChecking=no $1 "df -h /dbvol" >> '/tmp/version_check_mysql.txt'

echo "Size in GB"
echo "**********************"
cat $server_stat | grep $3
echo "***************Table Structure for $3*************"
cat $table_struc

cat '/tmp/version_check_mysql.txt'
