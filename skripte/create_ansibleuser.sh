#!/bin/bash
RANDOMPASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
ANSIBLEUSER="ansible"

egrep "^$ANSIBLEUSER" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	echo "$ANSIBLEUSER exists!"
	exit 1
else
	PASS=$(perl -e 'print crypt($ARGV[0], "password")' $RANDOMPASSWD)
	useradd -m -p $PASS --shell /bin/bash $ANSIBLEUSER > /dev/null
	if [ $? -eq 0 ]; then
		usermod -a -G sudo $ANSIBLEUSER
		echo "[*] Benutzer $ANSIBLEUSER zum System hinzugefügt" 
		echo "$ANSIBLEUSER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
		echo $(date) >> /root/ansible_user.log
		echo "Passwort für den Benutzer $ANSIBLEUSER:" >> /root/ansible_user.log
		echo $RANDOMPASSWD >> /root/ansible_user.log
		echo -e "\n" >> /root/ansible_user.log
		apt update >/dev/null 2>&1
		apt install openssh-server -y >/dev/null 2>&1
		mkdir /home/ansible/.ssh
		touch /home/ansible/.ssh/authorized_keys
		echo "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAokbXtkZQULelXPXXcetzQeN7ygK1bUov9f0p/XsEiikL/1iNlDi6DhjhZREKMCftrI4NM9+rsgTcBebuFjwD58wAeQBsszGXMhXALBBKoKDxx+wp21vCOEpsYTuMMkWFm3BzJAMPLyVEq4xVMC6bRHb0enfROH/oz3+/yoQmowceIuA== ansible@ansible01" > /home/ansible/.ssh/authorized_keys
		sed -i 's/PermitRootLogin\ prohibit-password/PermitRootLogin\ no/g' "/etc/ssh/sshd_config"
		sed -i 's/PermitRootLogin\ yes/PermitRootLogin\ no/g' "/etc/ssh/sshd_config"
		sed -i 's/UsePAM\ yes/UsePAM\ no/g' "/etc/ssh/sshd_config"
		sed -i 's/PasswordAuthentication\ yes/PasswordAuthentication\ no/g' "/etc/ssh/sshd_config"
		sed -i 's/PubkeyAuthentication\ no/PubkeyAuthentication\ yes/g' "/etc/ssh/sshd_config"
		/bin/systemctl restart sshd.service
		echo "[*] Benutzer: $ANSIBLEUSER  zur sudo-Gruppe hinzugefügt und SSH-Keys hinzugefügt"
		if [[ -f "/usr/bin/python" ]]; then
			echo "[*] \"/usr/bin/python\" gefunden"
		else
			ln -s /usr/bin/python3 /usr/bin/python
			echo "[*] Symbolischen Link zu \"/usr/bin/python\" erstellt"
		fi
		echo "[*] Einrichtung des Ansible-Benutzers erfolgreich abgeschlossen"
	else
		echo "[!] Failed to add a user!"
	fi
	
fi

