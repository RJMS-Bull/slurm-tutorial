#!/bin/sh

docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 -d -p 11134:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name ctld --hostname ctld docker-slurmctld
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 -d -p 11135:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c0 --hostname c0 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 -d -p 11136:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c1 --hostname c1 docker-slurmd
sleep 2

#pkill slurmctld
#sed -i "s/#JobAcctGatherFrequency=30.*/JobAcctGatherFrequency=30/g" /etc/slurm/slurm.conf
#sed -i "s/#JobAcctGatherType=jobacct_gather/linux.*/JobAcctGatherType=jobacct_gather/linux/g" /etc/slurm/slurm.conf
#sed -i "s/#AccountingStorageType=accounting_storage/slurmdbd.*/AccountingStorageType=accounting_storage/slurmdbd/g" /etc/slurm/slurm.conf
#sed -i "s/#AccountingStorageHost=localhost.*/AccountingStorageHost=localhost/g" /etc/slurm/slurm.conf
#sed -i "s/#AccountingStorageLoc=slurmDB.*/AccountingStorageLoc=slurmDB/g" /etc/slurm/slurm.conf
#sed -i "s/#AccountingStorageUser=root.*/AccountingStorageUser=root/g" /etc/slurm/slurm.conf
#mysql_install_db --user=mysql --ldata=/var/lib/mysql/
#mysqld_safe --user=mysql &
#slurmdbd
#clush -bw c[0-2] pkill slurmd
#clush -bw c[0-2] -c /etc/slurm/slurm.conf
#clush -bw c[0-2] slurmd
#sacctmgr add cluster taiwan
#slurmctld
