#!/bin/sh -e
#
# Introspect module for shoop. Expands the BASE class with an introspect
# method, that can list all methods and variables that are defined on a class.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <doogie@debian.org>

# Enable introspection inside _shoop
_shoop_introspect=1

_shoop_quote="'"
BASE . serialize : '
	local DEFINES A DISPLAYOBJ;
	if [ "$2" ]; then
		DISPLAYOBJ=$2;
	else
		DISPLAYOBJ=$THIS;
	fi;
	eval DEFINES=\$_shoopdefines_$THIS;
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			eval echo -n "$DISPLAYOBJ . $A\ ";
			if eval [ \"\$_shoopfinal_${THIS}_$A\" ]; then
				echo -n :;
			fi;
			if eval [ \$_shooptype_${THIS}_$A = variable ]; then
				echo -n "= ";
				$DISPLAYOBJ . $A;
			else
				echo -n ": $_shoop_quote";
				eval echo -n "\$_shoop_${THIS}_$A";
				echo -n "$_shoop_quote";
			fi;
			echo ;
			eval _shoopseen_$A="1";
		fi;
	done;
	if [ "$1" = resolve ];then
		for P in $($THIS . parent 2>/dev/null >/dev/null); do
			$P . serialize resolve $DISPLAYOBJ;
		done;
	fi;
	for A in $DEFINES; do
		unset _shoopseen_$A;
	done
'
