#!/bin/sh -e
#
# Destroy module for shoop. Expands the OBJECT class with a destroy method
# that completly whipes out any object it is called on (if that object has
# children, they stick around, so use with caution.
#
# LGPL copyright 2000 by Joey Hess <joey@kitenet.net>

# Enable introspection inside _shoop
_shoop_introspect=1


## This module allows one to destroy a shoop object.  It also erases the
## entire cache.

IFS=" " OBJECT . destroy :p '
	eval local A DEFINES=\$_shoopdefines_$THIS METH TRUEMETH
	for A in $DEFINES; do
		METH=$A TRUEMETH=${THIS}_$A
		if [ -z "$_shoopnocache_" ]; then
			eval $_shoopcacheclear_
		fi
		unset _shooptype_$TRUEMETH _shoopfinal_$TRUEMETH _shoop_TRUEMETH
	done
	# Unfortunately, destroying an object can have really weird side
	# effects to the cache tree.  It is best just to erase the whole
	# thing, then attempting to figure out which parts need to be
	# erased.
	eval unset _shoopdefines_$THIS $THIS _shoopcache_ \$_shoopcache_
'
