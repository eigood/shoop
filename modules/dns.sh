#!/bin/sh -e
#
# LGPL copyright 2000 by Adam Heath <doogie@debian.org>


_shoop_quote="'"
OBJECT . new DNS

IFS=" " DNS . builddns :p '
	local counter\
		title=$($THIS . title) domain=$($THIS . domain)\
		mx=$($THIS . mx) address=$($THIS . address)\
		num_ns=$($THIS . num_ns)
	exec 3>&1
	echo $($THIS . file)
	echo ";"
	echo "; Domain name server configuration file - $title"
	echo ";"
	echo
	echo "@ IN SOA ns1.$domain root.ns1.$domain ("
	echo "	$($THIS . serial)"
	echo "	$($THIS . refresh)"
	echo "	$($THIS . retry)"
	echo "	$($THIS . expire)"
	echo "	$($THIS . ttl)"
	echo ")"
	echo
	if [ "$address" ]; then
		echo "	IN A	$address"
	fi
	if [ "$mx" ]; then
		echo "	IN MX	$mx"
	fi
	echo
	for counter in $(seq -s " " 1 $num_ns); do
		echo "	IN NS	ns$counter.$domain."
#		echo "ns$counter	IN A	$($THIS . ns_ip_$counter)"
	done
	echo
	for counter in $($THIS . hosts 2>/dev/null); do
		echo "$counter	IN A	$($THIS . host_ip_$counter)"
		: bar
		mx=$($THIS . host_mx_$counter 2>/dev/null)
		if [ "$mx" ];then
			echo "	IN MX	$mx"
		fi
	done
	echo
	for counter in $($THIS . cnames 2>/dev/null); do
		echo "$counter	IN CNAME	$($THIS . cname_$counter)"
		: bar
		mx=$($THIS . host_mx_$counter 2>/dev/null)
		if [ "$mx" ];then
			echo "	IN MX	$mx"
		fi
	done
	echo
	for counter in $($THIS . hosts 2>/dev/null); do
		echo "$($THIS . host_ip_$counter)	IN PTR	$counter.$($THIS . domain)."
	done
'
IFS=" " DNS . host :p '
	local host=$1; shift
	if [ -z "$($THIS . host_ip_$host 2>/dev/null)" ]; then
		$THIS . hosts =q "$($THIS . hosts 2>/dev/null) $host"
	fi
	$THIS . host_ip_$host =q "$@"
'
IFS=" " DNS . cname :p '
	local host=$1; shift
	if [ -z "$($THIS . cname_$host 2>/dev/null)" ]; then
		$THIS . cnames =q "$($THIS . cnames 2>/dev/null) $host"
	fi
	$THIS . cname_$host =q "$@"
'
IFS=" " DNS . gethost :p '$THIS . host_ip_$1'
DNS . host_mx :p '
	local host=$1;shift
	$THIS . host_mx_$host =q "$@"
'

IFS=" " DNS . serialize :p '
	local DISPLAYOBJ=$THIS oldargs="$@" PARENTS=$($THIS . parent)
	set -- $PARENTS
	if [ "$1" ]; then
		if [ $# -gt 1 ]; then
			echo "$THIS . parent $PARENTS"
		fi
		eval _shoopseen_parent=1
	fi
	set -- $oldargs
	$THIS . super "dummy" $DISPLAYOBJ
'
