#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1
	local TRYOBJ=$2
	_shoop_current_method=$3
	shift 3

	if [ "$1" = = -o "$1" = : ]; then
		# This block is for introspect.
		if [ "$_shoop_introspect" ] &&
		   eval [ "$_shoop_introspect" -a -z "\$_shooptype_${TRYOBJ}_$_shoop_current_method" ]; then
			eval "_shoopdefines_$TRUEOBJ=\"\$_shoopdefines_$TRUEOBJ $_shoop_current_method\""
		fi
		
		if [ "$1" = = ]; then
			shift
			eval "_shooptype_${TRUEOBJ}_$_shoop_current_method=variable;
			      _shoop_${TRUEOBJ}_$_shoop_current_method () { echo -n $@; }"
			echo -n $@
		else
			shift
			eval "_shooptype_${TRUEOBJ}_$_shoop_current_method=method;
			      _shoop_${TRUEOBJ}_$_shoop_current_method () { $@
}"
		fi
	elif eval [ \"\$_shooptype_${TRYOBJ}_$_shoop_current_method\" ]; then
		eval _shoop_${TRYOBJ}_$_shoop_current_method $TRUEOBJ \"\$@\";
	else
		eval local PARENTS=\"`_shoop_${TRYOBJ}_parent`\"
		local P
		# Try inheritance 1 level deep -- the quick way.
		# TODO: benchmark to see if this helps.
		#    (remember, it also lets errors be seen..)
		for P in $PARENTS; do
			if eval [ -n \"\$_shooptype_${P}_$_shoop_current_method\" ]; then
				_shoop $TRUEOBJ $P $_shoop_current_method $@
				return $?
			fi
		done
		# When the quick way fails, try the hard way.
		for P in $PARENTS; do
			if _shoop $TRUEOBJ $P $_shoop_current_method $@ 2>/dev/null; then
				return 0
			fi
		done
		echo "\"$_shoop_current_method\" is undefined." >&2
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
BASE . super : '_shoop $1 $($1 . parent) $_shoop_current_method $@'

# Now if you want it, you have to turn it back on.
unset _shoop_introspect
