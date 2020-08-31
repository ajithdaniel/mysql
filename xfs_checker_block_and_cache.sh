#/bin/sh
# mkdir -p /home/bull/scripts/xfscheck and copy this file to xfs_checker.sh
# * * * * * sh /home/bull/scripts/xfscheck/xfs_checker.sh
scriptLoc='/home/bull/scripts/xfscheck'
scriptLog="/home/bull/scripts/xfscheck/logs/$(date +'%m-%d-%Y').log"
#sleep interval in seconds
interval=6
alertid="mysql-critical-alerts@olaprod.pagerduty.com  mysql-bull-check@olaprod.pagerduty.com"
​
if [ ! -d "$scriptLoc/logs" ];
	then
	mkdir -p $scriptLoc/logs
fi
​
check_XFS()
{
#echo "\n #### watching dmesg at $(date)##### \n"
​
dmesg -T | tail -1 | grep -e "XFS.*possible memory allocation deadlock size" > $scriptLoc/tail.txt
dmesg -T | tail -1 | grep -e "Executing drop caches" > $scriptLoc/lock.txt
​
if [ -s $scriptLoc/tail.txt ]
	then
​
echo "\n------------------------------------- \n"
cat $scriptLoc/tail.txt
echo "\n------------------------------------- \n"
​
        echo "[$(date)] : Found xfs warning on dmesg executing drop caches and alerting"
​
	echo "Process $$ $0 Executing drop caches" >>/dev/kmsg
​
	echo 2 > /proc/sys/vm/drop_caches
​
	PD="XFS warning on $(hostname) at $(date +%d_%B_%Y-%Hh-%Mm-%Ss)"
	echo "$PD" | mailx -s "$PD" $alertid
​
elif [ -s $scriptLoc/lock.txt ]
	then
	echo "[$(date)] : cache drop already running"
​
else
	echo "[$(date)] : No XFS warning on dmesg"
fi
#echo "\n #### END OF LINE ########\n"
}
​
# execute script n times bases on interval second
counter=$(echo $((60/$interval)))
for i in $(seq 1  $(echo $counter));
do
check_XFS | tee -a $scriptLog 2>&1
sleep $interval
done
find $scriptLoc/logs/ -type f -mtime +30 -delete
