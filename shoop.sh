#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1 TRYOBJ=$2 METH=$3 TRUEMETH=${1}_$3 TRYMETH=${2}_$3
	shift 3
	case "$1" in
		=|=q|.=|.=q|:)
			local varmeth=$1 append="" quiet=""; shift
			# This block is for introspect.
			if [ "$_shoop_introspect" ] &&
			   eval [ -z \"\$_shooptype_$TRYMETH\" ]; then
				eval "_shoopdefines_$TRUEOBJ=\"\$_shoopdefines_$TRUEOBJ $METH\""
			fi
			if [ -z "$_shoopnocache_" ]; then
				eval $_shoopcacheclear_
			fi
			# Some various assignment modifiers.
			if [ "${varmeth#.}" != $varmeth ]; then append=1 varmeth=${varmeth#.}; fi
			if [ "${varmeth%q}" != $varmeth ]; then quiet=1 varmeth=${varmeth%q}; fi
			if [ "$varmeth" = = ]; then
				if [ "$append" ];then eval "set -- $(eval eval "\$_shoop_$TRUEMETH")$@"; fi
				if [ ! "$quiet" ]; then echo -n $@; fi

				eval "_shoop_$TRUEMETH='echo -n $@'
				      _shooptype_$TRUEMETH=variable"
			else
				if [ "$quiet" ]; then echo "Invalid modified(q) on assignment!($TRUEOBJ.$METH)" >&2; fi
				if [ "$append" ];then
					eval eval "_shoop_$TRUEMETH=\'\$_shoop_$TRUEMETH;\$@\'
					      _shooptype_$TRUEMETH=method"
				else
					eval "_shoop_$TRUEMETH='$@'
					      _shooptype_$TRUEMETH=method"
				fi
			fi
			return
		;;
	esac
	if eval [ \"\$_shooptype_$TRYMETH\" ]; then
		local THIS=$TRUEOBJ
		eval eval "\$_shoop_$TRYMETH"
		return
	else
		eval local P PARENTS=\"$(eval eval "\$_shoop_${TRYOBJ}_parent")\"\
			THIS=$TRUEOBJ GETMETH="" NEWPARENTS=""
		if [ -z "$_shoopnocache_" ]; then
			# If this object is found in the cache, than short-circuit
			# the resolving code.
			eval local CACHE=\"\$_shoopcache_link_$TRUEMETH\"
			if [ "$CACHE" ]; then
				eval eval \$$CACHE
				return
			fi
		fi
		# 1st stage resolver.  Look at the immediate parents.
		for P in $PARENTS; do
			eval GETMETH=\"\$_shoop_${P}_$METH\"
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
		# 1st stage found no match, so resolve the inheritance tree,
		# starting at the second level, and loop over untested super
		# classes.
		local orgargs="$@"
		set -- $NEWPARENTS
		while [ $# -gt 0 ];do
			P=$1
			eval GETMETH="\$_shoop_${P}_$METH"
			if [ "$GETMETH" ]; then
				set -- "$orgargs"
				# Save a reference to the resolved object in the cache for the
				# true object.
				if [ -z "$_shoopnocache_" ]; then
					eval _shoopcache_link_${THIS}_$METH=_shoop_${P}_$METH\
					     _shoopcache_=\"\$_shoopcache_\
						  _shoopcache_method_$METH _shoopcache_link_${THIS}_$METH \"\
					     _shoopcache_method_$METH=\"\$_shoopcache_method_$METH\
						  _shoopcache_link_${THIS}_$METH\"\
					     _shoopcache_linkmethod_${P}_$METH=\"\$_shoopcache_linkmethod_${P}_$METH\
						  _shoopcache_link_${THIS}_$METH\"
				fi
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
# _shoopcache_link_DESCENDENT_counter=_shoop_OBJECT_counter
# _shoopcache_= _shoopcache_method_new _shoopcache_link_GRANDCHILD_new  _shoopcache_method_counter _shoopcache_link_DESCENDENT_counter 
# _shoopcache_method_counter= _shoopcache_link_DESCENDENT_counter
# _shoopcache_linkmethod_OBJECT_counter= _shoopcache_link_DESCENDENT_counter

			# Ok, the current METH is already in someone's cache.
			# Find out if it is THIS object that is referenced.
				# Someone is referencing \$METH, and it isn't TRUEMETH, so
				# that means we have to erase all references for \$METH.
				#
				# TODO: Only erase if $TRUE was in the parent path of
				# \$_shoopcache_method_\$METH
IFS=" " _shoopcacheclear_="
	if eval [ \\\"\\\$_shoopcache_method_\$METH\\\" ]; then
		eval echo \\\"\\\$_shoopcache_linkmethod_\$TRUEMETH\\\"
		if eval [ -z \\\"\\\$_shoopcache_linkmethod_\$TRUEMETH\\\" ]; then
			eval unset _shoopcache_method_\$METH\
				 \\\$_shoopcache_method_\$METH\
				   _shoopcache_linkmethod_\$TRUEMETH\
				 \\\$_shoopcache_linkmethod_\$TRUEMETH
		fi
	fi
"
# Temporarily turn on introspection, so the base object has everything 
# recorded about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.

# TODO: clear cache !!!!<<<< CRITICAL >>>>!!!!
# Not as simple as it first looks, because you can set your
# parents to non-existant objects, and then define those parents
# later.  Maybe we should not allow that, tho?

IFS=" " _shoop OBJECT OBJECT new : '
	local OBJNAME=$1;
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; };"
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
