#!/bin/shg -e
# OOP in shell.

# First parameter is object name.
# Second parameter is method or property to call.
# Remainder of paremters are passed to the method.
oosh () {
	_oosh $1 $@
}
_oosh () {
	local TRUEOBJ=$1
	local TRYOBJ=$2
	local METH=$3
	shift 3
	
	. $TRYOBJ.shobj
	if ! eval ${TRYOBJ}_$METH $TRUEOBJ $@ 2>/dev/null; then
		if [ "`${TRYOBJ}_parent 2>/dev/null`" ]; then
			_oosh $TRUEOBJ `${TRYOBJ}_parent` $METH $@
		else
			echo "No such method $METH" >&2
			exit 1
		fi
	fi
}

oosh BAR hello
oosh FOO hello
