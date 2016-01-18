#!/bin/bash
#
# Liest NginX-Logfile ein und gibt sie etwas übersichtlicher aus
#
if [ $# -eq 0 ]
then
	FILE=/var/log/nginx/access.log
else
	if [ -f /var/log/nginx/access.log.$1 ]
	then
		FILE=/var/log/nginx/access.log.$1
	else
		echo -e "[!] File not found!"
		exit 1
	fi
fi
COUNT=$(cat $FILE | wc -l)
echo -e "\n[*] $COUNT Zugriffe\n"
if [ $COUNT != 0 ]
then
	echo -e "\tIP\tAnfrage\tZiel\t\tBrowser"
	cat $FILE | awk '{FS="\"";print $1,$2,$6}' | awk '{print $1"\t"$6"\t"$7"\t\t"$9}' | grep -v '192.168' | uniq
	IP=$(cat $FILE | awk '{print $1}' | grep -v '192.168' | uniq) 
	echo -e "\n[*] HOSTS\n"
	getent hosts $IP | awk '{print $1"\t"$2}' | uniq | grep -v 'local' | grep -v -i 'xer'
fi	

echo -e "\n[*] Beendet mit Exit-Code: $(echo $?)\n"

