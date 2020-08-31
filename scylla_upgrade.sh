#!/bin/bash
set -x
# Usage : Upgrade scylla to latest version; eg.2.3 to 3.07(latest)
# Author : Ajith Daniel Poul
​
# function to upgrade scylla
scylla_upgrade()
{
nodetool describecluster
nodetool drain
nodetool snapshot
for conf in $( rpm -qc $(rpm -qa | grep scylla) | grep -v contains ); do sudo cp -v $conf $conf.backup-$old_version; done
systemctl stop scylla-server
rpm -qa | grep scylla-server
yum list | grep -i 'scylla-server'
yum install epel-release -y
curl -o /etc/yum.repos.d/scylla.repo -L http://repositories.scylladb.com/scylla/repo/9e8cc606-7322-4040-8796-41e6057df1d0/centos/scylladb-3.0.repo
yum update scylla\* -y
sed -i "s/api_address: 127.0.0.1/api_address: `hostname -i`/" /etc/scylla/scylla.yaml
sed -i 's/hinted_handoff_enabled: false//p' /etc/scylla/scylla.yaml
printf "\n#Enabling hinted handoff\nhinted_handoff_enabled: true" >> /etc/scylla/scylla.yaml
systemctl stop node-exporter
rm /usr/bin/node_exporter
node_exporter_install
systemctl start scylla-server
}
​
# main
# check version before and after the upgrade
​
old_version=$(scylla --version)
echo "Old Version is $old_version"
echo "Upgrading Scylla"
scylla_upgrade  2>upgrade.debug
new_version=$(scylla --version)
echo "New Version is $new_version"
​
if [ "$old_version" != "$new_version" ]
then
    echo "Scylla-Server is upgrade from $old_version to $new_version"
	echo "Please check errors using journalctl _COMM=scylla for 5 mins"
else
    echo "Scylla-Server upgrade failed"
fi
