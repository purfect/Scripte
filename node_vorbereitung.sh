#!/bin/bash
apt update 
apt install vim htop curl wget bash-completion git glusterfs-server
apt dist-upgrade -V
echo -e "%rasputin ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
wget https://raw.githubusercontent.com/purfect/Scripte/master/install_ca.sh
chmod +x install_ca.sh
./install_ca.sh
sed -i 's/PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/g' /etc/ssh/sshd_config
echo -e "PasswordAuthentication yes" >> /etc/ssh/sshd_config
sed -i 's/UsePAM\ yes/UsePAM\ no/g' /etc/ssh/sshd_config
systemctl restart sshd.service
echo -e "192.168.0.2\t ubuntu01" >> /etc/hosts
echo -e "192.168.0.3\t ubuntu02" >> /etc/hosts
echo -e "192.168.0.4\t ubuntu03" >> /etc/hosts
echo -e "192.168.0.5\t lb" >> /etc/hosts
apt-get install software-properties-common -y
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.2/ubuntu xenial main'
apt update
apt install mariadb-server
mysql_secure_installation
echo "Vorbereitungen abgeschlossen!"
