#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoopgetparent() {
	local a
	for a in $(eval eval "\$_shoop_${1}_parent"); do
		if eval [ -z \"\$_shoopresolve_parent_echo_$a\" ]; then
			eval _shoopresolve_parent_echo_$a=1
			echo $a
		fi
		if eval [ -z \"\$_shoopresolve_parent_get_$a\" ]; then
			eval _shoopresolve_parent_get_$a=1
			_shoopgetparent $a
		fi
	done
}
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
		if [ -z "$PARENTS" ]; then
			return 0
		fi
		local P
		# Try inheritance 1 level deep -- the quick way.
		# TODO: benchmark to see if this helps.
		#    (remember, it also lets errors be seen..)
		for P in $PARENTS; do
			if eval [ -n \"\$_shooptype_${P}_$METH\" ]; then
				local THIS=$TRUEOBJ
				eval eval "\$_shoop_${P}_$METH"
				return
			fi
		done
		# 1 level deep found no match, so resolve the inheritance
		# tree, and loop over untested super classes.

		# Tell getparent that we have already checked the first
		# level of parents.  However, getparent still needs to
		# walk the entire parent tree.
		for P in $PARENTS; do
			eval _shoopresolve_parent_echo_$P=1
		done
		local PARENTS2="$(_shoopgetparent $TRYOBJ)"
		local UNSET
		for P in $PARENTS; do
			UNSET="$UNSET _shoopresolve_parent_echo_$P"
		done
		for P in $PARENTS2; do
			UNSET="$UNSET _shoopresolve_parent_echo_$P _shoopresolve_parent_get_$P"
		done
		eval unset $UNSET
		for P in $PARENTS2; do
			if eval [ -n \"\$_shooptype_${P}_$METH\" ]; then
				local THIS=$TRUEOBJ
				eval eval "\$_shoop_${P}_$METH"
				return
			fi
		done
		if [ "$PARENTS" ];then
			echo "\"$METH\" is undefined for $TRYOBJ." >&2
			return 1
		fi
	fi
	return 0
}

# Temporarily turn on introspection, so the base object has everything recorded
# about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.
IFS=" " _shoop OBJECT OBJECT new : '
	local OBJNAME=$1;
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }";
	if [ $THIS != $OBJNAME ]; then
		_shoop $OBJNAME $OBJNAME parent = $THIS >/dev/null;
	fi
'
# Create the base object via the method already defined on it.
_shoop OBJECT OBJECT new OBJECT

# This method handles calling an overridden method of your parent.
# Sadly, you have to pass in the method name to call.
OBJECT . super : '_shoop $THIS $($THIS . parent) $@'

# Now if you want introspection, you have to turn it back on.
unset _shoop_introspect
