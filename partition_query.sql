select table_schema,table_name,partition_name,
CASE length(partition_description)
WHEN 6 then from_days(partition_description)
WHEN 10 then from_unixtime(left(partition_description,10)) 
WHEN 11 then from_unixtime(partition_description - to_seconds('1970-01-01 00:00:00')) 
WHEN 13 then from_unixtime(left(partition_description,10)) 
END as 
formatted_date,table_rows from information_schema.partitions where partition_name is not null  and table_schema not in ('test','information_schema','performance_schema','mysql') order by table_schema,table_name,partition_description
