#!/bin/sh -e
#
# Introspect module for shoop. Expands the OBJECT class with an introspect
# method, that can list all methods and variables that are defined on a
# class.
#
# Smell the Java. LGPL copyright 2000 by Adam Heath <doogie@debian.org>

## When called it will print out a brief synopsis of the methods and
## variables defined for the current object.  If passed the parameter
## C<resolve>, it will walk the parent tree, and print out everything,
## all the way back to the base OBJECT.
## 
## If you are going to use introspection, it is suggested you C<use>
## it early, as the introspection hooks are not normally enabled.

# Enable introspection inside _shoop
_shoop_introspect=1

IFS=" " OBJECT . introspect :p '
	local DEFINES A
	if [ -z "$2" ]; then
		local DISPLAYOBJ=$THIS
	fi
	eval DEFINES=\$_shoopdefines_$THIS
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			echo -n "$DISPLAYOBJ($THIS): "
			if eval [ \"\$_shoopfinal_${THIS}_$A\" ]; then
				echo -n "final "
			fi
			eval echo "$A is \$_shooptype_${THIS}_$A"
			eval local _shoopseen_$A="1"
		fi;
	done
	# This does not use a non-recursive form, as this code does not
	# need to be fast.  It is only for informative output.
	if [ "$1" = resolve ];then
		for P in $($THIS . parent); do
			$P . introspect resolve $DISPLAYOBJ
		done
	fi
	return
'
