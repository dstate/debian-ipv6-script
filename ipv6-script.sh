#!/bin/sh

usage="usage: $0 enable|disable"
rebootmsg="Done. You can now reboot."

ipv6file="/etc/sysctl.d/disableipv6.conf"
hostsfile="/etc/hosts"
sshfile="/etc/ssh/ssh_config"

ipv6content="net.ipv6.conf.all.disable_ipv6=1"

hostcontentipv6="::1\tip6-localhost\tip6-loopback\nfe00::0\tip6-localnet\nff00::0\tip6-mcastprefix\nff02::1\tip6-allnodes\nff02::2\tip6-allrouters"
hostpattern="ip6-"

sshcontentipv6="AddressFamily inet"


if [ "$1" = "enable" ]; then
	if [ -f $hostsfile ]; then
		cp $hostsfile $hostsfile.old
		if ! grep "$hostpattern" $hostsfile > /dev/null; then
			echo $hostcontentipv6 >> $hostsfile
		fi
	fi

	if [ -f $sshfile ]; then
		cp $sshfile $sshfile.old
		cat $sshfile | grep -v "$sshcontentipv6" > $sshfile.tmp
		mv $sshfile.tmp $sshfile
	fi

	rm -f $ipv6file

	echo $rebootmsg
elif [ "$1" = "disable" ]; then
	if [ -f $hostsfile ]; then
		cp $hostsfile $hostsfile.old
		cat $hostsfile | grep -v "$hostpattern" > $hostsfile.tmp
		mv $hostsfile.tmp $hostsfile
	fi

	if [ -f $sshfile ]; then
		cp $sshfile $sshfile.old
		if ! grep "$sshcontentipv6" $sshfile > /dev/null; then
			echo $sshcontentipv6 >> $sshfile
		fi
	fi

	echo $ipv6content > $ipv6file

	echo $rebootmsg
else
	echo $usage
fi
