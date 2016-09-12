#!/bin/sh

pkill slurmctld
sed -i "s/#JobAcctGatherFrequency=30.*/JobAcctGatherFrequency=30/g" /usr/local/etc/slurm.conf
sed -i "s/#JobAcctGatherType=jobacct/JobAcctGatherType=jobacct/g" /usr/local/etc/slurm.conf
sed -i "s/#AccountingStorageType=accounting/AccountingStorageType=accounting/g" /usr/local/etc/slurm.conf
sed -i "s/#AccountingStorageHost=localhost.*/AccountingStorageHost=localhost/g" /usr/local/etc/slurm.conf
sed -i "s/#AccountingStorageLoc=slurmDB.*/AccountingStorageLoc=slurmDB/g" /usr/local/etc/slurm.conf
sed -i "s/#AccountingStorageUser=root.*/AccountingStorageUser=root/g" /usr/local/etc/slurm.conf
mysql_install_db --user=mysql --ldata=/var/lib/mysql/
mysqld_safe --user=mysql &
slurmdbd
clush -bw c[0-1] pkill slurmd
clush -bw c[0-1] -c /usr/local/etc/slurm.conf
clush -bw c[0-1] slurmd
sacctmgr -i add cluster taiwan
slurmctld

