#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1 TRYOBJ=$2 METH=$3 TRUEMETH=${1}_$3 TRYMETH=${2}_$3
	shift 3

	if [ "$1" = = -o "$1" = := -o "$1" = : -o "$1" = :: ]; then
		local FINAL DEFINE
		# This block is for introspect.
		if [ "$_shoop_introspect" ] &&
			eval [ -z \"\$_shooptype_$TRYMETH\" ]; then
				eval "_shoopdefines_$TRUEOBJ=\"\$_shoopdefines_$TRUEOBJ $METH\""
		fi
		
		if [ "$1" = = ]; then
			shift
			eval "_shoop_$TRUEMETH='echo -n $@'
			      _shooptype_$TRUEMETH=variable"
			echo -n $@
		else
			shift
			eval "_shoop_$TRUEMETH='$@'
			      _shooptype_$TRUEMETH=method"
		fi
	elif eval [ \"\$_shooptype_$TRYMETH\" ]; then
		local THIS=$TRUEOBJ
		eval eval "\$_shoop_$TRYMETH"
	else
		eval local PARENTS=$(eval eval "\$_shoop_${TRYOBJ}_parent")
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
			if ! _shoop $TRUEOBJ $P $METH $@ 2>/dev/null; then
				return 0
			fi
		done
		echo "\"$METH\" is undefined for $TRYOBJ." >&2
		return 1
	fi
}

# Temporarily turn on introspection, so the base object has everything recorded
# about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.
_shoop BASE BASE new : '
	local OBJNAME=$1;
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }";
	if [ $THIS != $OBJNAME ]; then
		_shoop $OBJNAME $OBJNAME parent = $THIS >/dev/null;
	fi
'
# Create the base object via the method already defined on it.
_shoop BASE BASE new BASE

# This method handles calling an overridden method of your parent.
# Sadly, you have to pass in the method name to call.
BASE . super : '_shoop $THIS $($THIS . parent) $@'

# Now if you want introspection, you have to turn it back on.
unset _shoop_introspect
