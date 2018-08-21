#!/bin/bash
#
# Liest NginX-Logfile ein und gibt sie etwas übersichtlicher aus
#
######CONFIG############
FILE=./access.log
LOCALNET='192.168'
########################
function callhelp ()
{
	echo -e "\n\033[35mNginX-Logchecker v$VERSION\033[0m\n"
	echo -e "\033[1mInfo:\033[0m\nDieses Script liest die unter der Variable \$FILE angegebene NginX-Logdatei ein und stellt den Inhalt in einer uebersichtlichen Form da.\n\n"
	echo -e "\033[1mOptionen:\033[0m\n"
	echo -e "-h\t\t ruft diese Hilfeseite auf\n"
	echo -e "--detail\tes werden mehr Informationen angezeigt (Timestamp, Dubletten werden nicht entfernt). ANMERKUNG: Sollte eine Nummer mit angegeben werden, muss diese Option immer an letzter Stelle stehen\n" 
	echo -e "<Nummer>\twird eine Nummer (Integer) als Parameter uebergeben, wird diese Nummer an die Logdatei angehangen um aeltere Logdateien aufzurufen\n"
	echo -e "\t\t.$0 1 liest die Datei $FILE.1\n"
	exit 0
}
if [ "$1" == "-h" ]
then
	callhelp
fi
if [ $# -gt 0 ] && [ "$1" != "--detail" ]
then
	if [ -f $FILE."$1" ]
	then
		FILE=$FILE.$1
	else
		echo -e "\n\033[31m[!]\033[0m File not found!\n"
		exit 1
	fi
fi
ALLCOUNT=$(cat "$FILE" | wc -l)
INTERNCOUNT=$( grep $LOCALNET "$FILE" | wc -l)
echo -e "\n\033[32m[*]\033[0m \033[35m\033[1mNginX-Logchecker v$VERSION\033[0m\n"
echo -e "\033[32m[*]\033[0m \033[1m-h\033[0m fuer Hilfe und weitere Optionen\n"
echo -e "\033[32m[*]\033[0m $ALLCOUNT Zugriffe insgesamt\n"
if [ "$ALLCOUNT" != 0 ]
then
	if [ "$INTERNCOUNT" -gt 0 ]
        then
		let DIFF=$ALLCOUNT-$INTERNCOUNT
                echo -e "\033[32m[*]\033[0m $INTERNCOUNT LAN-Zugriff(e)\n"
                echo -e "\033[32m[*]\033[0m $DIFF externe Zugriff(e) \n"
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
	echo -e "\n\033[32m[*]\033[0m HOSTS\n"
	getent hosts $IP | awk '{print $1"\t"$2}' | uniq
fi
echo -e "\n\033[32m[*]\033[0m Beendet mit Exit-Code: $(echo $?)\n"
