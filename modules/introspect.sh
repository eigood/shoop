#!/bin/sh -e
#
# Introspect module for shoop. Expands the BASE class with an introspect
# method, that can list all methods and variables that are defined on a class.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <doogie@debian.org>

# Enable introspection inside _shoop
_shoop_introspect=1

BASE . introspect : '
	local OBJNAME=$1 DEFINES A DISPLAYOBJ;
	shift;
	if [ "$2" ]; then
		DISPLAYOBJ=$2;
	else
		DISPLAYOBJ=$OBJNAME;
	fi;
	eval DEFINES=\$_shoopdefines_$OBJNAME;
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			eval echo "$DISPLAYOBJ\($OBJNAME\): $A is \$_shooptype_${OBJNAME}_$A";
			eval _shoopseen_$A="1";
		fi;
	done;
	if [ "$1" = resolve ];then
		for P in $($OBJNAME . parent); do
			$P . introspect resolve $DISPLAYOBJ;
		done;
	fi;
	for A in $DEFINES; do
		eval unset _shoopseen_$A;
	done
'
