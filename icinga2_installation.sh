#!/bin/sh
#
# Installationsscript für Icinga 2
# mit Percona als MySQL-Backend
#
######[ Root-Check ]######
if [ "$(id -u)" != "0" ]
then
    echo "[!] Dieses Script läuft nur mit Root-Rechten"
    exit 1
fi
###
MySQLPASSWORT=$(openssl rand -base64 32)
ICINGA2MYSQLPASSWORT=$(openssl rand -base64 32)
ICINGAWEBAPIPASSWORT=$(openssl rand -base64 32)
IDOMYSQLBENUTZER="icinga2"
####
echo "[*] Binde Icinga-Repos ein"
# Importieren der Icinga-Keys
rpm --import https://packages.icinga.com/icinga.key 1>/dev/null
# Einbinden der Icinga2-Repos
yum install -y https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm 1>/dev/null
echo "[*] Binde EPEL-Repo ein"
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 1>/dev/null
echo "[*] Baue Yum-Cache neu"
yum clean all >/dev/null 2>&1 && yum makecache 1>/dev/null
echo "[*] Installiere Icinga2 & Nagios-Plugins"
yum -y install icinga2 nagios-plugins-all icinga2-selinux >/dev/null 2>&1
echo "[*] Starte Icinga 2"
systemctl start icinga2.service && systemctl enable icinga2.service >/dev/null 2>&1
echo "[*] Installiere Percona"
yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm 1>/dev/null
yum install -y Percona-Server-server-57 icinga2-ido-mysql 1>/dev/null
echo "[*] Starte Percona-Instanz"
systemctl start mysqld.service
TMPMYSQLPASSWORT=$(grep -i password /var/log/mysqld.log | awk '{ print $NF}')
echo "[*] Temporäres MySQL-Passwort: $TMPMYSQLPASSWORT"
echo "[*] Setze das neues MySQL-Passwort: $MySQLPASSWORT"
mysql --connect-expired-password -uroot -p$TMPMYSQLPASSWORT -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MySQLPASSWORT';" >/dev/null 2>&1
echo "[*] Überprüfe die Änderung des Passwortes"
mysql -uroot -p$MySQLPASSWORT -e "SELECT User, Host, HEX(authentication_string) FROM mysql.user;" 2>/dev/null
echo "[*] Erstelle Icinga2-Datenbank"
mysql -uroot -p$MySQLPASSWORT -e "CREATE DATABASE icinga2;" >/dev/null 2>&1
echo "[*] Erstelle Icinga2-Datenbankbenutzer"
mysql -uroot -p$MySQLPASSWORT -e "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga2.* TO 'icinga2'@'localhost' IDENTIFIED BY '$ICINGA2MYSQLPASSWORT';" >/dev/null 2>&1
echo "[*] Passwort für Icinga2-Datenbankbenutzer: $ICINGA2MYSQLPASSWORT" 
mysql -uroot -p$MySQLPASSWORT -e "flush privileges;" >/dev/null 2>&1
echo "[*] Erstelle Datenbank-Schema"
mysql -uroot -p$MySQLPASSWORT icinga2 < /usr/share/icinga2-ido-mysql/schema/mysql.sql >/dev/null 2>&1
echo -e "[*] Aktiviere \"ido-mysql\" "
icinga2 feature enable ido-mysql >/dev/null 2>&1
echo -e "[*] Erstelle \"ido-mysql\" Konfiguration"
echo -e "object IdoMysqlConnection \"ido-mysql\" {" > /etc/icinga2/features-enabled/ido-mysql.conf
echo -e "user = \"$IDOMYSQLBENUTZER\"" >> /etc/icinga2/features-enabled/ido-mysql.conf
echo -e "password = \"$ICINGA2MYSQLPASSWORT\"" >> /etc/icinga2/features-enabled/ido-mysql.conf
echo -e "host = \"localhost\""  >> /etc/icinga2/features-enabled/ido-mysql.conf
echo -e "database = \"icinga2\"" >> /etc/icinga2/features-enabled/ido-mysql.conf
echo -e "}" >> /etc/icinga2/features-enabled/ido-mysql.conf
echo "[*] Reload von Icinga 2"
systemctl reload icinga2.service
echo "[*] Aktiviere API-Feature"
icinga2 feature enable api >/dev/null 2>&1
icinga2 api setup >/dev/null 2>&1
echo "[*] Konfiguriere API-Feature"
echo -e "object ApiUser \"icingaweb2\" {" >> /etc/icinga2/conf.d/api-users.conf
echo -e "password = \"$ICINGAWEBAPIPASSWORT\"" >> /etc/icinga2/conf.d/api-users.conf
echo -e "permissions = [" >> /etc/icinga2/conf.d/api-users.conf
echo -e "\t\"status/query\"," >> /etc/icinga2/conf.d/api-users.conf
echo -e "\t\"actions/*\"," >> /etc/icinga2/conf.d/api-users.conf
echo -e "\t\"objects/modify/*\"," >> /etc/icinga2/conf.d/api-users.conf
echo -e "\t\"objects/query/*\"," >> /etc/icinga2/conf.d/api-users.conf
echo -e "]" >> /etc/icinga2/conf.d/api-users.conf
echo -e "}" >> /etc/icinga2/conf.d/api-users.conf
echo  -e "[*] Passwort für API-Benutzer \"icingaweb2\": $ICINGAWEBAPIPASSWORT"
echo "[*] Reload von Icinga 2"
systemctl reload icinga2.service
echo -e "[*] Installiere \"Software Collection for Linux\""
yum install -y centos-release-scl >/dev/null 2>&1
echo "[*] Installiere Apache, Icinga Web 2 und IcingaCLI"
yum -y install httpd icingaweb2 icingacli >/dev/null 2>&1
groupadd -r icingaweb2; >/dev/null 2>&1
usermod -a -G icingaweb2 apache; >/dev/null 2>&1
sed -i -e "s/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Berlin/g" /etc/opt/rh/rh-php71/php.ini
echo "[*] Starte Webserver"
systemctl start httpd.service && systemctl enable httpd.service >/dev/null 2>&1
echo "[*] Starte PHP-FPM-Dienst"
systemctl start rh-php71-php-fpm.service && systemctl enable rh-php71-php-fpm.service >/dev/null 2>&1
echo "[*] Erstelle Icinga Web 2 Konfigurationsverzeichnis"
icingacli setup config directory --group icingaweb2; 1>/dev/null
echo "#######################################"
echo "[*] Passwörter:"
echo "MySQL-Root: $MySQLPASSWORT"
echo "MySQL-Icinga2: $ICINGA2MYSQLPASSWORT"
echo "API Icingaweb-Benutzer: $ICINGAWEBAPIPASSWORT"
echo "#######################################"
echo "[*] Erstelle Token "
icingacli setup token create;