# Deploy a Slurm cluster upon a PC using Docker

This tutorial provides the basic blocks to create a Slurm cluster based on Docker.
It can be used as a tool to train administrators to configure and deploy different Slurm functionalities 
and to help users to learn the different ways they can use Slurm under specific configurations.


#### Prerequisites

- You need to have Docker installed, and an internet connection for at least the first deployment.
	* In case you already have the docker-slurm image no internet connection is needed. 

### 1. Download the tutorial code

You can either download the code in zip format by using the Download ZIP button of github
or use the git command to clone the repository.

```
$ git clone https://github.com/RJMS-Bull/slurm-tutorial.git
```
### 2. Launch the deployment of the cluster

Go to the directory of the code. 

```
$ cd slurm-tutorial
```
You can see the procedure the deployment is going to follow by opening the launch.sh file in that directory:

```
$ cat launch.sh
#!/bin/sh

######build images step

#comment the next line in case you already have docker-slurm image and no internet connection
docker build -t docker-slurm .
cd docker_slurmctld_build/
docker build -t docker-slurmctld .
cd ../docker_slurmd_build/
docker build -t docker-slurmd .

#####deploy cluster step

docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11134:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name ctld --hostname ctld docker-slurmctld
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11135:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c0 --hostname c0 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11136:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c1 --hostname c1 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11137:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c2 --hostname c2 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11138:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c3 --hostname c3 docker-slurmd
```
In the first usage of the script and if you don't have docker-slurm image the procedure will build everything
from scratch "build images step" . This might take some time depending on the quality of the connection.

There is one main docker image called docker-slurm that contains all packages and 2 other images which specialize on the role of the node within the cluster.
The docker-slurmctld image will be used for the controller side (slurmctld and slurmdbd daemons) whereas the docker-slurmd image for the compute nodes (slurmd daemon).
Once the build process is finished the procedure continues in deploying the cluster based on the images created "deploy cluster step" .

Execute the launch.sh script by using the following command:

```
$ ./launch.sh
```
When the above script has finished execution without errors the cluster will be ready for usage.

### 3. Connect to the deployed cluster 
 
Connect on the controller machine:

```
$ docker exec -t -i ctld /bin/bash
```
If everything worked fine until now you will be connected upon the controller of the cluster.

```
[root@ctld slurm-16.05.4]#
```
You can start using the Slurm cluster by issuing different Slurm commands:

```
[root@ctld slurm-16.05.4]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 1-00:00:00      4   idle c[0-3]
[root@ctld slurm-16.05.4]# srun -n3 -N3 /bin/hostname
c0
c2
c1
```
#### Change Slurm configuration

The configuration files for Slurm can be found under /usr/local/etc/

For a configuration parameter to take effect you can make changes on the slurm.conf file of the controller, then transfer
the file on all compute nodes and restart the daemons. For this you can use clush command which exists within the already deployed environment.

```
[root@ctld slurm-16.05.4]# clush -bw c[0-3] -c /usr/local/etc/slurm.conf
[root@ctld slurm-16.05.4]# clush -bw c[0-3] pkill slurmd
[root@ctld slurm-16.05.4]# pkill slurmctld
[root@ctld slurm-16.05.4]# clush -bw c[0-1] slurmd
[root@ctld slurm-16.05.4]# slurmctld
```
### 4. Activate Slurm database with slurmdbd daemon

By default the usage of the database is desactivated. However the database in Slurm is a core feature upon which many features rely such as
users accounts and limitations, jobs accounting and reporting along with scheduling algorithms such as fairsharing and preemption.

While on the controller. Execute the following script:

```
[root@ctld slurm-16.05.4]# /opt/slurm-16.05.4/launch_DB.sh
```
This will change the slurm.conf file to activate the mysql database, it will initialize the slurm database and restart daemons for 
the changes to take effect.

You can now use the sacct command to follow the accounting of jobs.

```
[root@ctld slurm-16.05.4]# sacct
       JobID    JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- -------- 
2              hostname     normal       root          3  COMPLETED      0:0 
4              hostname     normal       root          3  COMPLETED      0:0 
```

#### Use the cluster as a simple user

root has advanced priviledges when using Slurm commands. You can change to user guest in order to see how a simple user can make use of the Slurm cluster.

```
[root@ctld slurm-16.05.4]# su guest
[guest@ctld slurm-16.05.4]$
[guest@ctld slurm-16.05.4]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 1-00:00:00      4   idle c[0-3]
[guest@ctld slurm-16.05.4]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[guest@ctld slurm-16.05.4]$ srun -n3 /bin/hostname
c0
c0
c0
[guest@ctld slurm-16.05.4]$ sacct
       JobID    JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- -------- 
5              hostname     normal                     3  COMPLETED      0:0 
```
For example a simple user doesn't have the right to see the accounting of root's jobs

Since ssh is activate within the node and it is possible to go around from the controller to the compute nodes with ssh. Here is the guest password
"guest1234"

### 5. Hands-ON: Experiment with Slurm configuration and usage through exercises

Now that the Slurm cluster is up and running you can start experimenting following the tutorial and the hands-on exercises available
on the slides here: [SLURM_Tutorial_Cluster2016.pdf](https://github.com/RJMS-Bull/slurm-tutorial/blob/master/SLURM_Tutorial_Cluster2016.pdf)




