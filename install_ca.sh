#!/bin/bash
USER="rasputin"

echo "[*] Anlegen der CA"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC64uz6nTWr52gYyU6OYQzud1nCIBxVA6Gk2PusJRM8TO3dERkP9uErUewz2gQPx3/6bQ8R1NQ/BuOGdHot6CVoDqBaEM8wH2fz6MdhSZEowEXARkZz3Kc/dcogTxqvkmZPGKCQd4zRKr82GEvBNxYoXIzm8R/HY9SOhF/ONOVtGUp4YimSH/4ZGQmXwzd4/HQl2tLkY6zSxXjhK136KPBW1WqmzFUFe4oF+n72DvweEwIdt4qb3zgcbaBmNJ8pg2S+FYfuoGLghkLFIYSKC5ZrKavF77Ogsh/l9lpb4EekcTHwsmSbCyMeBHb62Ps8QWRE9soXuo1h5CDt3VIgafG9 CA" > /etc/ssh/ca.pub
echo "TrustedUserCAKeys /etc/ssh/ca.pub" >> /etc/ssh/sshd_config
echo "[*] Einrichten der Principals"
mkdir -p /var/ssh/auth_principals
echo "AuthorizedPrincipalsFile /var/ssh/auth_principals/%u" >> /etc/ssh/sshd_config
echo -e 'zone-webservers\nroot-everywhere' > /var/ssh/auth_principals/root
echo -e 'zone-webservers\nroot-everywhere' > /var/ssh/auth_principals/$USER
echo "[*] Neustarten des SSH-Dienstes"
/bin/systemctl restart sshd.service
echo "[*] Einrichtung angeschlossen!"

