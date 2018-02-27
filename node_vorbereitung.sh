#!/bin/bash
apt update 
apt install vim htop curl wget bash-completion git
apt dist-upgrade -V
echo -e "%rasputin ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
wget https://raw.githubusercontent.com/purfect/Scripte/master/install_ca.sh
chmod +x install_ca.sh
./install_ca.sh
sed -i 's/PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/g' /etc/ssh/sshd_config
echo -e "PasswordAuthentication yes" >> /etc/ssh/sshd_config
sed -i 's/UsePAM\ yes/UsePAM\ no/g' /etc/ssh/sshd_config
systemctl restart sshd.service
