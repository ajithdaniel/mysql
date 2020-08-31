#!/bin/bash
logs_dir='/home/bull/scripts/postges_health/logs'
date_day=`date +%F`
date_min=`date +%F_%H:%M`
file_prefix=postgresstatus-Un2-Matser.$date_min
​
​
​
mkdir -p $logs_dir/$date_day/
LogFile=$logs_dir/$date_day/$file_prefix
touch $logs_dir/$date_day/$file_prefix
​
export PGPASSWORD='a9GwQXfSn33kjs43z4kYPAFU'
psql --log-file=$LogFile  -h 'urbanninjaasia.cmufchfu0wrp.ap-south-1.rds.amazonaws.com' -U 'masteruser' -d 'postgres'  <<EOF
​
SELECT now(),COUNT(*) FROM pg_stat_activity;
SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state;
SELECT now(),usename,count(*) from pg_stat_activity group by  usename;
SELECT COUNT(DISTINCT pid) FROM pg_locks WHERE granted = false;
SELECT COUNT(DISTINCT pid) AS count FROM pg_locks WHERE NOT GRANTED;
SELECT relation::regclass, COUNT(*) AS count FROM pg_locks WHERE NOT GRANTED GROUP BY 1;
SELECT MAX(NOW() - xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction', 'active');
SELECT TRIM(TRAILING ';' FROM a.query) AS blocking_statement, \
       EXTRACT('epoch' FROM NOW() - a.query_start) AS blocking_duration \
  FROM pg_locks bl JOIN pg_stat_activity a \
    ON a.pid = bl.pid \
WHERE NOT bl.GRANTED;
select client_addr,count(*) from pg_catalog.pg_stat_activity group by  client_addr order by  count(*) desc;
SELECT   pid, now() - pg_stat_activity.query_start AS duration, query, state FROM pg_stat_activity WHERE (now() - pg_stat_activity.query_start) > interval '1 minutes';
select * from  pg_stat_activity;
EOF
Collapse
