#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1 TRYOBJ=$2 METH=$3 TRUEMETH=${1}_$3 TRYMETH=${2}_$3
	shift 3
	if [ "$1" = = -o "$1" = : ]; then
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
			return
		else
			shift
			eval "_shoop_$TRUEMETH='$@'
			      _shooptype_$TRUEMETH=method"
			return
		fi
	elif eval [ \"\$_shooptype_$TRYMETH\" ]; then
		local THIS=$TRUEOBJ
		eval eval "\$_shoop_$TRYMETH"
		return
	else
		eval local P PARENTS=\"$(eval eval "\$_shoop_${TRYOBJ}_parent")\" THIS=$TRUEOBJ GETMETH="" NEWPARENTS=""
		# Try inheritance 1 level deep -- the quick way.
		for P in $PARENTS; do
			eval GETMETH="\$_shoop_${P}_$METH"
			if [ "$GETMETH" ]; then
				eval "$GETMETH"
				return
			fi
			# Save the parents of the current parents, for use in the
			# 2nd stage resolver.  Yes, this slows the 1st stage down,
			# but barely.  However, it greatly speeds up the 2nd stage,
			# which is where most of the time will be spent.  This
			# gave an 8% speedup in the 2nd stage, and only noise in
			# the first.
			NEWPARENTS="$NEWPARENTS $(eval eval "\$_shoop_${P}_parent")"
		done
		# 1 level deep found no match, so resolve the inheritance
		# tree, and loop over untested super classes.

		local orgargs="$@"
		set -- $NEWPARENTS
		while [ $# -gt 0 ];do
			P=$1
			eval GETMETH="\$_shoop_${P}_$METH"
			if [ "$GETMETH" ]; then
				set -- "$orgargs"
				eval "$GETMETH"
				return
			fi
			shift
			set -- $(eval eval "\$_shoop_${P}_parent") "$@"
		done
		echo "\"$METH\" is undefined for $TRYOBJ." >&2
		return 1
	fi
}

# Temporarily turn on introspection, so the base object has everything 
# recorded about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.
IFS=" " _shoop OBJECT OBJECT new : '
	local OBJNAME=$1;
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }";
	if [ $THIS != $OBJNAME ]; then
		_shoop $OBJNAME $OBJNAME parent = $THIS >/dev/null;
	fi;
	return
'
# Create the base object via the method already defined on it.
_shoop OBJECT OBJECT new OBJECT
OBJECT . parent = ""

# This method handles calling an overridden method of your parent.
# Sadly, you have to pass in the method name to call.
OBJECT . super : '_shoop $THIS $($THIS . parent) $@; return'

# Now if you want introspection, you have to turn it back on.
unset _shoop_introspect
