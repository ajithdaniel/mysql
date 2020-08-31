mysqladmin shutdown
​
mv /dbvol /old_dbvol
​
mkdir /dbvol
​
disks=$(lsblk | grep nvme | sed -e 's/.*nvme\(.*\)n1.*/\1/' | tr -d '\n')
​
num=${#disks}
​
if [ $num -ge 2 ]
then
​
echo "No.of Disk > 1; creating lvm with $num stripes"
​
apt-get install lvm2
​
pvcreate /dev/nvme[$disks]n1
​
vgcreate vg_dbvol /dev/nvme[$disks]n1
​
lvcreate -l 100%FREE --stripes $num --stripesize 512 -n lvm vg_dbvol
​
{
hostname | grep -w azure
if [ $? -eq 1 ];
then 
echo "/dev/mapper/vg_dbvol-lvm  /dbvol  xfs noatime 0 0" >> /etc/fstab
else
echo "/dev/mapper/vg_dbvol-lvm /dbvol xfs  defaults,nofail,x-systemd.requires=cloud-init.service,comment=cloudconfig       0       2" >> /etc/fstab
fi
}
​
​
mkfs.xfs /dev/mapper/vg_dbvol-lvm
​
elif [ $num -eq 1 ]
then
echo "No.of Disk = 1; mounting it with xfs"
​
mkfs.xfs -f /dev/nvme0n1
​
{
hostname | grep -w azure
if [ $? -eq 1 ];
then 
echo "/dev/nvme0n1 /dbvol xfs noatime,nobootwait 0 0" >> /etc/fstab
else
echo "/dev/nvme0n1 /dbvol xfs  defaults,nofail,x-systemd.requires=cloud-init.service,comment=cloudconfig       0       2" >> /etc/fstab
fi
}
else 
​
echo "Invalid no.of Disks"
​
fi
​
mount -a
​
mv /old_dbvol/mysql /dbvol/
​
chown -R mysql.mysql /dbvol
​
mysqld_safe --defaults-file=/dbvol/mysql/etc/my.cnf &
