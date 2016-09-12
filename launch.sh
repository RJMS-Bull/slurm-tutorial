#!/bin/sh

#build images
#comment the next line in case you already have docker-slurm and no internet connection
#docker build -t docker-slurm .
#cd docker_slurmctld_build/
#docker build -t docker-slurmctld .
#cd ../docker_slurmd_build/
#docker build -t docker-slurmd .
#cd ../

#deploy cluster
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11134:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name ctld --hostname ctld docker-slurmctld
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11135:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c0 --hostname c0 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11136:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c1 --hostname c1 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11137:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c2 --hostname c2 docker-slurmd
sleep 2
docker run --privileged --add-host ctld:172.17.0.2 --add-host c0:172.17.0.3 --add-host c1:172.17.0.4 --add-host c2:172.17.0.5 --add-host c3:172.17.0.6 -d -p 11138:22 -it -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup  --name c3 --hostname c3 docker-slurmd

