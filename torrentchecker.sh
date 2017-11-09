#!/bin/bash                                                
#                                                          
# Aktualisierung von Manjaro- und Antergos Torrents        
#                                                          
##############                                             
# Allgemeine Pfade                                         
##############                                             
TORRENTPFAD="/var/lib/transmission/.config/transmission-daemon/torrents"                                              
TORRENTDOWNLOADPFAD="/var/lib/transmission/Downloads"      
LOGFILE="/root/torrentchecker.log"                         
#                                                          
# Manjaro                                                  
#                                                          
FINDTORRENT=$(curl -sq https://manjaro.org/get-manjaro/ | grep torrent | grep xfc | grep 64 | awk -F "\"" '{print $2}')                                                                                                                      
NEWTORRENT=$(echo $FINDTORRENT | awk -F "/" '{print $NF}') 
if [ ! -f "$TORRENTPFAD/$NEWTORRENT" ]                     
then                                                       
    rm -f $TORRENTPFAD/manjaro*                            
    wget $FINDTORRENT -O $TORRENTPFAD/$NEWTORRENT          
    rm -f $TORRENTDOWNLOADPFAD/manjaro*                    
    if [ "$?" == 0 ]                                       
    then                                                   
        /usr/bin/systemctl restart transmission-daemon.service                                                        
        echo $(/usr/bin/date) >> $LOGFILE                  
        echo "neue manjaro-Version hinzugefügt" >> $LOGFILE
        echo " " >> $LOGFILE                               
    else                                                   
        exit 1                                             
    fi                                                     
fi                                                         
#                                                          
# Antergos                                                 
#                                                          
ANTERGOSTORRENT=$(curl -sq https://antergos.com/try-it/ | grep torrent | grep -v minimal | awk -F "\"" '{print $6}')  
ANTERGOSNEWTORRENT=$(echo $ANTERGOSTORRENT  | awk -F "/" '{print $NF}')                                               
if [ ! -f "$TORRENTPFAD/$ANTERGOSNEWTORRENT" ]             
then                                                       
    rm -f $TORRENTPFAD/antergos*                           
    wget $ANTERGOSTORRENT -O $TORRENTPFAD/$ANTERGOSNEWTORRENT                                                         
    rm -f $TORRENTDOWNLOADPFAD/antergos*                   
    if [ "$?" == 0 ]                                       
    then                                                   
        /usr/bin/systemctl restart transmission-daemon.service                                                        
        echo $(/usr/bin/date) >> $LOGFILE                  
        echo "neue antergos-Version hinzugefügt" >> $LOGFILE                                                          
        echo " " >> $LOGFILE                               

    else                                                   
        exit 1                                             
    fi                                                     
fi        
