#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1
	local TRYOBJ=$2
	local METH=$3
	shift 3

	if [ "$1" = = -o "$1" = : ]; then
		# This block is for introspect.
		if [ "$_shoop_introspect" ] &&
		   eval [ "$_shoop_introspect" -a -z "\$_shooptype_${TRYOBJ}_$METH" ]; then
			eval "_shoopdefines_$TRUEOBJ=\"\$_shoopdefines_$TRUEOBJ $METH\""
		fi
		
		if [ "$1" = = ]; then
			shift
			eval "_shooptype_${TRUEOBJ}_$METH=variable;
			      _shoop_${TRUEOBJ}_$METH () { echo -n $@; }"
			echo -n $@
		else
			shift
			eval "_shooptype_${TRUEOBJ}_$METH=method;
			      _shoop_${TRUEOBJ}_$METH () { $@
}"
		fi
	elif eval [ \"\$_shooptype_${TRYOBJ}_$METH\" ]; then
		eval _shoop_${TRYOBJ}_$METH $TRUEOBJ \"\$@\";
	else
		eval local PARENTS=\"`_shoop_${TRYOBJ}_parent`\"
		local P
		# Try inheritance 1 level deep -- the quick way.
		# TODO: benchmark to see if this helps.
		#    (remember, it also lets errors be seen..)
		for P in $PARENTS; do
			if eval [ -n \"\$_shooptype_${P}_$METH\" ]; then
				_shoop $TRUEOBJ $P $METH $@
				return $?
			fi
		done
		# When the quick way fails, try the hard way.
		for P in $PARENTS; do
			if _shoop $TRUEOBJ $P $METH $@ 2>/dev/null; then
				return 0
			fi
		done
		echo "\"$METH\" is undefined." >&2
		return 1
	fi
}

# Temporarily turn on introspection, so the base object has everything recorded
# about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.
_shoop BASE BASE new : '
	local PARENT=$1
	local OBJNAME=$2
	
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }
	      $OBJNAME . parent = $PARENT >/dev/null"
'
# Create the base object via the method already defined on it.
_shoop_BASE_new '' BASE

# This method handles calling an overridden method of your parent.
# Sadly, you have to pass in the method name to call.
BASE . super : 'THIS=$1; shift; _shoop $THIS $($THIS . parent) $@'

# Now if you want it, you have to turn it back on.
unset _shoop_introspect
