#!/bin/sh -e
#
# Pretty-printing module for shoop. Expands the OBJECT class with a prettyprint
# method, that can list all methods and variables that are defined on a class,
# pretty-printing them.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <doogie@debian.org>

# Enable introspection inside _shoop
_shoop_introspect=1

IFS=" " OBJECT . prettyprint :p '
	local DEFINES A
	if [ -z "$2" ]; then
		local DISPLAYOBJ=$THIS
		echo "$3object $DISPLAYOBJ {"
	fi
	eval DEFINES=\$_shoopdefines_$THIS
	for A in $DEFINES; do
		if eval [ -z \"\$_shoopseen_$A\" ]; then
			echo -en "\t$3"
			if eval [ \"\$_shoopfinal_${THIS}_$A\" ]; then
				echo -n "final "
			fi
			eval echo -n "\$_shooptype_${THIS}_$A $A\ "
			if eval [ \$_shooptype_${THIS}_$A = variable ]; then
				echo -n "= "
				$DISPLAYOBJ . $A
			else
				echo -ne "{\n$3\t\t"
				eval echo "\$_shoop_${THIS}_$A"
				echo -ne "$3\t}"
			fi
			echo 
			eval local _shoopseen_$A="1"
		fi
	done
	# This does not use a non-recursive form, as this code does not
	# need to be fast.  It is only for informative output.
	if [ "$1" = resolve ];then
		for P in $($THIS . parent 2>/dev/null); do
			echo -e "\t$3class $P {"
			$P . introspect resolve $DISPLAYOBJ "$3\t"
			echo -e "\t$3}"
		done
	fi
	if [ -z "$2" ]; then
		echo "$3}"
	fi
'
