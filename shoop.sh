#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1
	local TRYOBJ=$2
	local METH=$3
	shift 3

	if [ "$1" = = ]; then
		# Set value.
		shift 1
		eval "_shoop_${TRUEOBJ}_${METH} () { echo $@; }"
		echo $@
	elif [ "$1" = : ]; then
		# Set method.
		shift 1
		eval "_shoop_${TRUEOBJ}_${METH} () { $@; }"
	elif ! eval _shoop_${TRYOBJ}_$METH $TRUEOBJ $@ 2>/dev/null; then
		if [ "$(_shoop_${TRYOBJ}_parent 2>/dev/null)" ]; then
			_shoop $TRUEOBJ $(_shoop_${TRYOBJ}_parent) $METH $@
		else
			echo "No such method, \"$METH\"" >&2
			return 1
		fi
	fi
}

# Create a base object class. All other objects will inherit from this.

# Method to create a new object. Pass the name of the object to create.
_shoop_BASE_new () {
	local PARENT=$1
	local OBJNAME=$2
	
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }"
	if [ "$PARENT" ]; then
		eval "_shoop_${OBJNAME}_parent () { echo $PARENT; }"
	fi
}
# Make the base object.
_shoop_BASE_new '' BASE
