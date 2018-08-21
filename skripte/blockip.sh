#!/bin/bash
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	iptables -A INPUT -s $1 -j DROP
	iptables-save | uniq | iptables-restore
	iptables-save > /etc/iptables/rules.v4
fi
