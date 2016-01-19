#!/bin/bash
#
# Liest NginX-Logfile ein und gibt sie etwas übersichtlicher aus
#
###### CONFIG ############
FILE=/var/log/nginx/access.log
LOCALNET='192.168' # zum herausfiltern von Anfragen aus dem LAN
##########################

# Neben der normalen access.log kann man auch ältere Logfiles 
# (z.B. access.log.1) betrachten, indem man die Nummer vom Logfile übergibt
# ohne Parameter wird die normale Logdatei eingelesen
# ./logcheck.sh 1 liest access.log.1 aus
if [ $# != 0 ]
then
	if [ -f $FILE.$1 ]
	then
		FILE=$FILE.$1
	else
		echo -e "[!] File not found!\n"
		exit 1
	fi
fi
ALLCOUNT=$(cat $FILE | wc -l)
INTERNCOUNT=$(cat $FILE | grep $LOCALNET | wc -l)
echo -e "\n[*] $ALLCOUNT Zugriffe insgesamt\n"
if [ $ALLCOUNT != 0 ]
then
	let DIFF=$ALLCOUNT-$INTERNCOUNT
	echo -e "[*] $INTERNCOUNT LAN-Zugriff(e)\n"
	echo -e "[*] $DIFF externe Zugriff(e) \n"

	echo -e "\tIP\tAnfrage\tZiel\t\tBrowser"
	cat $FILE | awk '{FS="\"";print $1,$2,$6}' | awk '{print $1"\t"$6"\t"$7"\t\t"$9}' | grep -v $LOCALNET | uniq
	IP=$(cat $FILE | awk '{print $1}' | grep -v $LOCALNET | uniq) 
	echo -e "\n[*] HOSTS\n"
	getent hosts $IP | awk '{print $1"\t"$2}' | uniq 
fi	

echo -e "\n[*] Beendet mit Exit-Code: $(echo $?)\n"
