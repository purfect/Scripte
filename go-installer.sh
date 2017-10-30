#!/bin/bash
INSTALLPATH="/usr/local"
GOWORKSPACE="/home/rasputin/go_projects/"
USER="rasputin"
GETGOVERSION=$(go version 2>/dev/null)
echo ""
if [ "$(which curl)" != "" ]
then
        WEB=$(curl -q -s https://golang.org/dl/ | grep 'linux-amd64' | awk -F'"' '{print $6}' | grep -v -e '^$' | head -n 1)
else
        echo -e "[!] Es wird cUrl benötigt!\n"
        exit 1
fi
echo -e "Go Installationspfad:\t\t$INSTALLPATH/go"
VERSION=$(echo $WEB | awk -F'/' '{print $NF}')
WEBSTRING="Go-Version zum Download:\t"$VERSION
if [ "$GETGOVERSION" != "" ]
then
      echo -e "Aktuell installiert:\t\t"$GETGOVERSION
fi
echo -e $WEBSTRING
echo ""
echo -n "Soll Go heruntergeladen und installiert werden? [J/n] "
read -n 1 EXECUTEINSTALL
echo ""
if [ "$EXECUTEINSTALL" == "n" ] || [ "$EXECUTEINSTALL" == "N" ]
then
        echo "[*] Auf Wiedersehen!"
        exit 0
fi
if [ "$EXECUTEINSTALL" != "j" ] && [ "$EXECUTEINSTALL" != "J" ] && [ "$EXECUTEINSTALL" != "" ]
then
        echo "[!] Falsche Eingabe!"
        exit 1
fi
echo "[*] Beginne Download von: "$VERSION
ADRESSE=$(curl -qs -I $(echo $WEB) | grep -i location | awk '{print $NF}' | awk -F'?' '{print $1}')
wget $ADRESSE
if [ ! -e "$VERSION" ]
then
        echo "[!] Download fehlgeschlagen, Datei im Ordner nicht gefunden!"
        echo "[*] Auf Wiedersehen!"
        exit 1
else
        echo "[*] Download war erfolgreich"
fi
if [ -d "$INSTALLPATH/go" ]
then
        echo "[*] Entfernen bestehendes Verzeichnis"
        rm -rf $(echo "$INSTALLPATH/go")
fi
echo "[*] Entpacke Go nach \"$INSTALLPATH/go\""
tar -C $INSTALLPATH -xzf $(echo $VERSION)
if [ "$(echo $?)" == 0 ]
then
        echo "[*] Go erfolgreich entpackt"
else
        echo "Go konnte nicht nach $INSTALLPATH entpackt werden"
        exit 1
fi
echo "[*] Lösche $VERSION"
rm $VERSION
echo "[*] Erstelle Benutzer-Verzeichnis für Go-Projekte"
if [ ! -d  $GOWORKSPACE"bin" ]
then 
    mkdir -p $GOWORKSPACE"bin"
fi 
if [ ! -d $GOWORKSPACE"src" ]
then
    mkdir -p $GOWORKSPACE"src"
fi 
if [ ! -d $GOWORKSPACE"pkg" ]
then
    mkdir -p $GOWORKSPACE"pkg"
fi 
chown -R $USER $GOWORKSPACE
echo "[*] Setze globale Variablen in /etc/profile"
sed -i '/\/go\/bin/d' /etc/profile
echo -e "export PATH=\$PATH:$INSTALLPATH/go/bin:$GOPATH/bin" >> /etc/profile
sed -i '/export\ GOPATH/d' /etc/profile
echo -e "export GOPATH=$GOWORKSPACE" >> /etc/profile
sed -i '/export\ GOBIN/d' /etc/profile
echo -e "export GOBIN=\$GOPATH/bin" >> /etc/profile
source /etc/profile
echo "[*] Installiert: "$(go version)
if [ $(echo $?) == 0 ]
then
        echo "[*] Installation erfolgreich!"
        echo -e "[*] Bitte führen Sie  noch den Befehl \"source /etc/profile\" aus damit Sie go verwenden können"
        echo "[*] Oder loggen Sie sich aus und wieder ein"
else
        echo "[!] Irgend etwas ist schiefgelaufen!"
fi
echo ""
