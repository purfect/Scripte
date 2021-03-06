#!/bin/bash

######[ Root-Check ]######
if [ "$(id -u)" != "0" ]
then
    echo "[!] Dieses Script läuft nur mit Root-Rechten"
    exit 1
fi

######[ Parameter ]######

CONTAINERSIZE=25  #Größe des Container's in MB
RANDOMNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
DATENOW=container_$(date +"%m-%d-%y-%T")

####[ Cryptsetup installiert? ]####
which cryptsetup > /dev/null
if [ $(echo $?) != 0 ]
then
	echo "[!] Bitte zuerst cryptsetup installieren"
	exit 1
fi

######[ Let's Rock ]######
echo "[*] Erstelle Container ($CONTAINERSIZE MB) aus Zufallszahlen"
dd if=/dev/urandom of="$RANDOMNAME" bs=1M count=$CONTAINERSIZE > /dev/null 2>&1  

if [ -f "$RANDOMNAME" ]
then
    echo "[*] Container erfolgreich erstellt"
    echo "[*] Container-Name: $RANDOMNAME"
    echo "[*] Container wird verschlüsselt"
    cryptsetup -c aes-xts-plain64 -s 512 -h sha512 -y --batch-mode luksFormat "$RANDOMNAME" 
    cryptsetup luksOpen "$RANDOMNAME" "$DATENOW" 
    echo "[*] Formatiere Coantainer"
    mkfs.ext4 -j /dev/mapper/"$DATENOW" > /dev/null 2>&1 
    echo "[*] Erstelle Mountpunkt"
    mkdir -p /mnt/"$RANDOMNAME"
    echo "[*] Hänge Container in das Dateisystem" 
    mount -t ext4 /dev/mapper/"$DATENOW" /mnt/"$RANDOMNAME"
    if [ $? -eq 0 ]
    then
    	echo "[*] Container erfolgreich eingehangen:"
    	df -h | grep "$DATENOW" 
    	echo ""
    	echo "[*] Passe Schreibrechte für den Container an"
    	chown -R rasputin /mnt 
    	echo "[*] FERTIG!"
    else
	echo "[!] Der Container konnte nicht eingehangen werden!"
    fi
else
    echo "[!] Container konnte nicht erstellt werden!"
fi
