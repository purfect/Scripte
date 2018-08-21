#!/bin/bash
PFAD="/home/user/tmp/vpntest/"

######[ Root-Check ]######
if [ "$(id -u)" != "0" ]
then
    echo "[!] Dieses Script läuft nur mit Root-Rechten"
    exit 1
fi

########[ Script ]########


echo "###################################"
echo -e "\tOPENVPN Standorte"
echo "###################################"
for entry in $PFAD*
do
	if [[ "$entry" == *.opvpn ]]
	then
		echo "$entry" | awk -F "/" '{print $NF}' | awk -F "." '{print $1}'
	fi
done
echo "Welcher Standort soll verwendet werden?"
read LOCATION

SUCHE=$(find "$PFAD" -iname "$LOCATION*") 
SUCHECOUNT=$(find "$PFAD" -iname "$LOCATION*" | wc -l) 
if [ "$SUCHECOUNT" == 0 ]
then
	echo "Es wurde keine passende Konfiguration gefunden!" 
	exit 1
elif [ "$SUCHECOUNT" -ge 2 ]
then 
	echo "Es wurden zu viel Standorte mit dem Suchstring gefunden!"
	exit 1
else 
	echo "$SUCHE wurde ausgewählt" 
	screen openvpn $SUCHE
	
fi
