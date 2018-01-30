#!/bin/bash
CAFILE="https://raw.githubusercontent.com/purfect/Scripte/master/ca/ca.pub"
USER="rasputin"

echo "[*] Herunterladen der CA"
wget $CAFILE -O /etc/ssh/ca.pub
echo "TrustedUserCAKeys /etc/ssh/ca.pub" >> /etc/ssh/sshd_config
echo "[*] Einrichten der Principals"
mkdir /etc/ssh/auth_principals
echo "AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u" >> /etc/ssh/sshd_config
echo -e 'zone-webservers\nroot-everywhere' > /etc/ssh/auth_principals/root
echo -e 'zone-webservers\nroot-everywhere' > /etc/ssh/auth_principals/$USER
echo "[*] Neustarten des SSH-Dienstes"
/bin/systemctl restart sshd.service
echo "[*] Einrichtung angeschlossen!"

