### Урок по NFS

vagrant up поднимает две ВМ:
- nfs-server
- nfs-client
и выполняет скрипты provision:

nfs-server-provision.sh
```
sudo yum install nfs-utils nfs-utils-lib -y
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
sudo mkdir -p /var/share/
sudo mkdir -p /var/share/upload
sudo chmod -R 777 /var/share/upload
echo "/var/share/ *(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
exportfs -r
sudo systemctl restart nfs-server
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=111/tcp
sudo firewall-cmd --permanent --add-port=54302/tcp
sudo firewall-cmd --permanent --add-port=20048/tcp
sudo firewall-cmd --permanent --add-port=2049/tcp
sudo firewall-cmd --permanent --add-port=2049/udp
sudo firewall-cmd --permanent --add-port=46666/tcp
sudo firewall-cmd --permanent --add-port=42955/tcp
sudo firewall-cmd --permanent --add-port=875/tcp
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --permanent --zone=public --add-service=mountd
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --reload
```
nfs-client-provision.sh
```
sudo yum install nfs-utils nfs-utils-lib -y
sudo systemctl enable rpcbind
sudo systemctl start rpcbind
sudo mkdir /mnt/share
echo "Nfsvers = 3" >> /etc/nfsmount.conf
sudo mount -t nfs 192.168.89.99:/var/share/ /mnt/share/
echo "192.168.89.99:/var/share/ /mnt/share/ nfs udp 0 0" >> /etc/fstab
```
Которые настраивают NFS сервер и файрволл, расшаривают папку /var/share и монтируют ее на клиента.

