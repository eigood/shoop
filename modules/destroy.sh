#!/bin/sh -e
#
# Destroy module for shoop. Expands the OBJECT class with a destroy method
# that completly whipes out any object it is called on (if that object has
# children, they stick around, so use with caution.
#
# GPL copyright 2000 by Joey Hess <joey@kitenet.net>

# Enable introspection inside _shoop
_shoop_introspect=1

IFS=" " OBJECT . destroy : '
	eval local A DEFINES=\$_shoopdefines_$THIS;
	for A in $DEFINES; do
		unset _shooptype_${THIS}_$A _shoopfinal_${THIS}_$A _shoop_${THIS}_$A;
	done;
	eval unset _shoopdefines_$THIS $THIS _shoopcache_ \$_shoopcache_
'
