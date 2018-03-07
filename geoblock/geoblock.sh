#!/bin/bash
ZONEDIR="zones"
if [ ! -d "$ZONEDIR" ] 
then
        mkdir $ZONEDIR
fi
echo "[*] Beginne mit dem herunterladen der Zonen"
wget --quiet -nv -r -nd -l 2 -A ??.zone http://www.ipdeny.com/ipblocks/ -P $ZONEDIR
if [ $? -eq 0 ]; then
        echo "[*] Zonen erfolgreich heruntergeladen"
fi

