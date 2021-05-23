#!/bin/bash

sudo yum install nfs-utils nfs-utils-lib -y
sudo systemctl enable rpcbind
#sudo systemctl enable nfs-server
#sudo systemctl enable nfs-lock
#sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
#sudo systemctl start nfs-server
#sudo systemctl start nfs-lock
#sudo systemctl start nfs-idmap
sudo mkdir /mnt/share
echo "Nfsvers = 3" >> /etc/nfsmount.conf
sudo mount -t nfs 192.168.89.99:/var/share/ /mnt/share/
echo "192.168.89.99:/var/share/ /mnt/share/ nfs udp 0 0" >> /etc/fstab
