#!/bin/bash
if [ -f /usr/bin/sshpass ]
then
	lxterminal -e sshpass -p "g3hEimes_P4ssW0rd" ssh -o StrictHostKeyChecking=no  -L 3390:192.168.1.10:3389 rdp-user@domäne.de &
	#sleep 8
	while true
	do
		[[ $(netstat -lpn 2>/dev/null | grep 3390 | grep ssh) ]]; 
		if [ $? -eq 0 ]
		then
			if [ "$1" == "f" ]
			then
				rdesktop -f -d domain.local -u benutzer 127.0.0.1:3390 2>/dev/null
				break
			else
				rdesktop -d domain.local -u benutzer 127.0.0.1:3390 2>/dev/null
				break
			fi
		else
			sleep 1
		fi
	done
else
	echo "SSHPass wurde nicht gefunden!"
fi
wait
