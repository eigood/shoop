#!/bin/sh -e
#
# Simplistic debian/rules module for shoop.
#
# LGPL copyright 2000 by Adam Heath <doogie@debian.org>

OBJECT . new DEBIAN

DEBIAN . processcmdline : '
	while [ $# -gt 0 ]; do
		var=$(echo "$1"|sed -n "s,^\([^ =	]*\)=,\1,p")
		if [ "$var" ];then
			value=$(echo "$1"|sed -n "s,^[^ =	]*=\"?\(.*\)\"?$,\1")
			eval $var=\"$value\";
			continue
		fi
		case "$1" in
			-j*)
				if [ "$1" = "-j" ];then
					$THIS . J_FLAG = $2;
					shift
				else
					$THIS . J_FLAG = $(echo $1|sed "s,^-j,,")
				fi
			;;
			*)
				$THIS . targets =q $($THIS . targets 2>/dev/null) $1
			;;
		esac;
		shift
	done;
	local a targets=$($THIS . targets 2>/dev/null);
	if [ -z "$targets" ]; then
		targets=$($THIS . default_target)
	fi;
	for a in $targets; do
		$THIS . $a
	done
'
DEBIAN . newpkg : '
	local pkg=$1; shift;
	$THIS . new $pkg;
	DEBIAN . pkgs .=q " $pkg"
'
DEBIAN . runpkg : '
	local method=$1 msg="$2" a; shift 2;
	for a in $(DEBIAN . pkgs); do
		echo $msg for $($a . pkg);
		$a . ${method}deps
	done
'

CURDIR=$PWD

DEBIAN . prefix = ${prefix:-$CURDIR} > /dev/null

DEBIAN . installfile : '
	if [ "$2" ]; then
		local base=$(basename $2) target=$($THIS . prefix);
		if [ $2 -nt $target/$base -o ! -e $target/$base ]; then
			echo install -m 644 $2 $target/$i;
			install -m 644 $2 $target/$i
		fi
	fi
'
DEBIAN . installdir : '
	local dir=$($THIS . prefix)/$1;
	if [ ! -d $dir ]; then
		echo install -m 755 $dir
		install -d -m 755 $dir
	fi
'
DEBIAN . installfiles : '
	local dir=$1 file; shift;
	for file in "$@"; do
		$THIS . installfile $dir $file
	done
'

DEBIAN . installdirs : '
	local dir;
	for dir in "$@"; do
		$THIS . installdir $dir
	done
'


DEBIAN . installpriv	: '
	local dir=$($THIS . $1);
	$THIS . installdir $dir;
	$THIS . installfiles $dir $($THIS . $2 2>/dev/null);
'

DEBIAN . installbins 		: '$THIS . installpriv bindir bins'
DEBIAN . installdocs		: '$THIS . installpriv docdir docs'
DEBIAN . installmodules		: '$THIS . installpriv moddir modules'
DEBIAN . installexamples	: '$THIS . installpriv empdir examples'
DEBIAN . installdeps		: '
	$THIS . installbins;
	$THIS . installdocs;
	$THIS . installmodules;
	$THIS . installexamples
'

DEBIAN . install		: '
	DEBIAN . build;
	DEBIAN . runpkg install Installing
'

DEBIAN . build		: '
	DEBIAN . configure;
	DEBIAN . runpkg build Building
'

DEBIAN . configure	: '
	DEBIAN . runpkg configure Configuring
'

DEBIAN . binary			: '$THIS . binary_indep; $THIS . binary_arch'
DEBIAN . binary_indep		: '$THIS . install'
DEBIAN . binary_arch		: '$THIS . install'
