#!/bin/sh -e
#
# Introspect module for shoop. Expands the OBJECT class with an introspect
# method, that can list all methods and variables that are defined on a class.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <doogie@debian.org>

# Enable introspection inside _shoop
_shoop_introspect=1

IFS=" " OBJECT . introspect : '
	local DEFINES A DISPLAYOBJ
	if [ "$2" ]; then
		DISPLAYOBJ=$2
	else
		DISPLAYOBJ=$THIS
	fi
	eval DEFINES=\$_shoopdefines_$THIS
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			echo -n "$DISPLAYOBJ($THIS): "
			if eval [ \"\$_shoopfinal_${THIS}_$A\" ]; then
				echo -n "final "
			fi
			eval echo "$A is \$_shooptype_${THIS}_$A"
			eval _shoopseen_$A="1"
		fi;
	done
	if [ "$1" = resolve ];then
		for P in $($THIS . parent); do
			$P . introspect resolve $DISPLAYOBJ
		done
	fi
	for A in $DEFINES; do
		eval unset _shoopseen_$A
	done
	return
'
