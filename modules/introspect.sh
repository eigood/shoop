#!/bin/sh -e
#
# Introspect module for shoop. Expands the BASE class with an introspect
# method, that can list all methods and variables that are defined on a class.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <doogie@debian.org>

# Enable introspection inside _shoop
_shoop_introspect=1

BASE . introspect : '
	local DEFINES A DISPLAYOBJ;
	if [ "$2" ]; then
		DISPLAYOBJ=$2;
	else
		DISPLAYOBJ=$_shoop_THIS;
	fi;
	eval DEFINES=\$_shoopdefines_$_shoop_THIS;
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			eval echo "$DISPLAYOBJ\($_shoop_THIS\): $A is \$_shooptype_${_shoop_THIS}_$A";
			eval _shoopseen_$A="1";
		fi;
	done;
	if [ "$1" = resolve ];then
		for P in $($_shoop_THIS . parent); do
			$P . introspect resolve $DISPLAYOBJ;
		done;
	fi;
	for A in $DEFINES; do
		eval unset _shoopseen_$A;
	done
'
