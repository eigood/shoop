#!/bin/sh -e
#
# Serialization module for shoop. Expands the OBJECT class with a serialize
# method, that can dump out machine-readable definitions of objects.
#
# For example: FOO . serialize > FOO.sh; exit
# To restart: . ./FOO.sh
#
# LGPL copyright 2000 by Adam Heath <doogie@debian.org>

## If you need to save the state of your objects, so that you can later
## restore their internal values, then include this into your shoop
## script.  Any object that you then wish to save should then be done
## with the following syntax:
## 
## C<FOO . serialize E<gt> save_FOO.sh>
# Enable introspection inside _shoop
_shoop_introspect=1

_shoop_quote="'"
IFS=" " OBJECT . serialize :p '
	local DEFINES A
	local PARENTS=$($THIS . parent 2>/dev/null)
	if [ -z "$2" ]; then
		local DISPLAYOBJ=$THIS oldargs="$@"
		set -- $PARENTS
		if [ "$1" ]; then
			echo "$1 . new $THIS"
			if [ $# -gt 1 ]; then
				echo "$THIS . parent $PARENTS"
			fi
			eval _shoopseen_parent=1
		fi
		set -- $oldargs
	fi
	eval DEFINES=\$_shoopdefines_$THIS
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			eval echo -n "$DISPLAYOBJ . $A\ "
			if eval [ \$_shooptype_${THIS}_$A = variable ]; then
				echo -n "= "
				$DISPLAYOBJ . $A
			else
				echo -n ": $_shoop_quote"
				IFS=" " eval echo -n "\$_shoop_${THIS}_$A"
				echo -n "$_shoop_quote"
			fi
			echo
			eval local _shoopseen_$A=1
		fi
	done
	if eval [ \"\$_shoopfinal_$DISPLAYOBJ\" ]; then
		eval echo "$DISPLAYOBJ . finalize \$_shoopfinal_$DISPLAYOBJ"
	fi
	# This does not use a non-recursive form, as this code does not
	# need to be fast.  It is only for informative output.
	if [ "$1" = resolve ];then
		for P in $PARENTS; do
			$P . serialize resolve $DISPLAYOBJ
		done
	fi
	return
'
