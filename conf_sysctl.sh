#!/bin/bash
####################################################################
# conf_sysctl.sh : tuning KErnel Linux pour faire fonctiopnner un max de
#                  process Java / participants DDS
####################################################################
# pur afficher les valeurs actuelles :
# > ipcs -l

[ $EUID -ne 0 ] && echo "Root please !" && exit 1

ipcs -l

echo "sleep 3" ; sleep 3

#
# Share-memory IPC SV
#
sysctl -w kernel.shmmax=173741824
sysctl -w kernel.shmmni=2048
sysctl -w kernel.shmall=262144


# semaphores: semmsl, semmns, semopm, semmni 
#             250 32000 100 1024 
#
# Pour rendre cela definitif :
# > echo "kernel.sem=250 32000 100 128" >> /etc/sysctl.conf

bash -c 'echo 1000 6400 200 1048 > /proc/sys/kernel/sem'

#
# Max thread : 500K >> 1M
#
echo 50000 > /proc/sys/kernel/threads-max

ipcs -l
