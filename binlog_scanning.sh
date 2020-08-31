#!/bin/bash
input="/dbvol/binlog/binlog_list1.txt"
rm /tmp/binlog_status.txt
while IFS= read -r line
do
echo $line
mysqlbinlog --base64-output=decode-rows -vvv $line > $line.txt
echo "************Binlog -$line ************"  >>/tmp/binlog_status.txt
echo "Binlog Time:"  >>/tmp/binlog_status.txt
head $line.txt | grep 'end_log_pos' | head -n 1 | awk '{print $1,$2}' >>/tmp/binlog_status.txt
cat $line.txt | grep -i  -e "^### update" -e "^### insert"  |  cut -c1-100 | tr '[A-Z]' '[a-z]' | sed -e "s/\t/ /g;s/\`//g;s/(.$//;s/ set .$//;s/ as .$//" | sed -e "s/ where .$//" |     sort | uniq -c | sort -nr  | head >>/tmp/binlog_status.txt
rm $line.txt
done < "$input"
