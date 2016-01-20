#!/bin/bash
#
# Liest NginX-Logfile ein und gibt sie etwas übersichtlicher aus
#
######CONFIG############
FILE=./access.log
LOCALNET='192.168'
########################
if [ $# -gt 0 ] && [ "$1" != "--detail" ]
then
	if [ -f $FILE."$1" ]
	then
		FILE=$FILE.$1
	else
		echo -e "[!] File not found!\n"
		exit 1
	fi
fi
ALLCOUNT=$(cat "$FILE" | wc -l)
INTERNCOUNT=$( grep $LOCALNET "$FILE" | wc -l)
echo -e "\n[*] $ALLCOUNT Zugriffe insgesamt\n"
if [ "$ALLCOUNT" != 0 ]
then
	if [ "$INTERNCOUNT" -gt 0 ]
        then
		let DIFF=$ALLCOUNT-$INTERNCOUNT
                echo -e "[*] $INTERNCOUNT LAN-Zugriff(e)\n"
                echo -e "[*] $DIFF externe Zugriff(e) \n"
        fi
if [ "$1" == "--detail" ] || [ "$2" == "--detail" ]
then
	echo -e "Zeitpunkt\t\t\tIP\tAnfrage\tZiel\t\tBrowser"
	cat $FILE | awk '{FS="\"";print $1,$2,$6}' | awk '{print $4"\t"$1"\t"$6"\t"$7"\t\t"$9}' | sed 's/[\[]//g' | grep -v $LOCALNET 
else
	echo -e "\tIP\tAnfrage\tZiel\t\tBrowser"
        cat "$FILE" | awk '{FS="\"";print $1,$2,$6}' | awk '{print $1"\t"$6"\t"$7"\t\t"$9}' | grep -v $LOCALNET | uniq
fi
IP=$(cat "$FILE" | awk '{print $1}' | grep -v $LOCALNET | uniq)
echo -e "\n[*] HOSTS\n"
getent hosts "$IP" | awk '{print $1"\t"$2}' | uniq
fi
echo -e "\n[*] Beendet mit Exit-Code: $(echo $?)\n"
