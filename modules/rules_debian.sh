#!/bin/sh -e

OBJECT . processcmdline : '
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
				$THIS . targets = $($THIS . targets) $1
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
CURDIR=$PWD

OBJECT . prefix = ${prefix:-$CURDIR} > /dev/null

OBJECT . installfile : '
	if [ "$2" ]; then
		local base=$(basename $2) target=$($THIS . prefix);
		if [ $2 -nt $target/$base -o ! -e $target/$base ]; then
			echo install -m 644 $2 $target/$i;
			install -m 644 $2 $target/$i
		fi
	fi
'
OBJECT . installdir : '
	local dir=$($THIS . prefix)/$1;
	if [ ! -d $dir ]; then
		echo install -m 755 $dir
		install -d -m 755 $dir
	fi
'
OBJECT . installfiles : '
	local dir=$1 file; shift;
	for file in "$@"; do
		$THIS . installfile $dir $file
	done
'

OBJECT . installdirs : '
	local dir;
	for dir in "$@"; do
		$THIS . installdir $dir
	done
'


OBJECT . installpriv	: '
	local dir=$($THIS . $1);
	$THIS . installdir $dir;
	$THIS . installfiles $dir $($THIS . $2 2>/dev/null);
'

OBJECT . installbins 		: '$THIS . installpriv bindir bins'
OBJECT . installdocs		: '$THIS . installpriv docdir docs'
OBJECT . installmodules		: '$THIS . installpriv moddir modules'
OBJECT . installexamples	: '$THIS . installpriv empdir examples'
OBJECT . install		: '
	$THIS . build;
	echo Installing for $($THIS . pkg);
	$THIS . installbins;
	$THIS . installdocs;
	$THIS . installmodules;
	$THIS . installexamples
'
OBJECT . binary			: '$THIS . binary_indep; $THIS . binary_arch'
OBJECT . binary_indep		: '$THIS . install'
OBJECT . binary_arch		: '$THIS . install'
