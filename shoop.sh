#!/bin/sh -e
# OOP in shell.
# LGPL copyright 2000 by Joey Hess <joey@kitenet.net>
#			 Adam Heath <doogie@debian.org>

_shoop () {
	local cmd=$1; shift
	local TRUEOBJ=$1 TRYOBJ=$2 METH=$3 TRUEMETH=$1_$3 TRYMETH=$2_$3 LASTMETH=$METH GETMETH THIS CLASS
	shift 3

	case "$cmd" in
		d)	if eval [ \"\$_shoopprivate_$TRUEMETH\" ]; then
				echo "Previous declaration of ($TRUEOBJ:$METH) marked private" >&2
				return 1
			fi
			unset _shoop_$TRUEMETH _shooptype_$TRUEMETH
			if [ -z "$_shoopnocache_" ]; then
				eval $_shoopcacheclear_
			fi
			return
			;;
	esac
	case "$1" in
		:|:p|.:|.:p|\=|\=q|\=p|\.\=|\.\=q|\.\=p|\.\=qp)
			local varmeth=$1 append="" quiet="" private=""; shift
			if [ "${varmeth%p}" != "$varmeth" ]; then private=1 varmeth=${varmeth%p}; fi
			# This block is for introspect.
			if [ "$_shoop_introspect" ] &&
			   eval [ -z \"\$_shooptype_$TRYMETH\$private\" ]; then
				eval "_shoopdefines_$TRUEOBJ=\"\$_shoopdefines_$TRUEOBJ $METH\""
			fi
			if [ -z "$_shoopnocache_" ]; then
				eval $_shoopcacheclear_
			fi
			# Some various assignment modifiers.
			if [ "${varmeth#.}" != "$varmeth" ]; then append=1 varmeth=${varmeth#.}; fi
			if [ "${varmeth%q}" != "$varmeth" ]; then quiet=1 varmeth=${varmeth%q}; fi
			if eval [ \"\$_shoopprivate_$TRYMETH\" ]; then
				echo "Previous declaration of ($TRYOBJ:$METH) marked private" >&2
				return 1
			fi
			if [ "$private" ]; then
				eval _shoopprivate_$TRYMETH=1
			fi
			if [ "$varmeth" = = ]; then
				if [ "$append" ];then set -- "$(eval eval "\$_shoop_$TRUEMETH") $@"; fi
				if [ ! "$quiet" ]; then eval "echo -n \"$@\""; fi

				if [ $# -eq 0 ]; then
					return
				fi
				eval "_shoop_$TRUEMETH='echo -n $@'
				      _shooptype_$TRUEMETH=variable"
			else
				if [ "$quiet" ]; then echo "Invalid modifier(q) on assignment!($TRUEOBJ.$METH)" >&2; fi
				if [ $# -eq 0 ]; then
					return
				fi
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
		THIS=$TRUEOBJ CLASS=$TRYOBJ
	else
		eval local PARENTS=\"$(eval eval "\$_shoop_${TRYOBJ}_parent")\"\
			NEWPARENTS=""
		THIS=$TRUEOBJ
		if [ -z "$_shoopnocache_" ]; then
			# If this object is found in the cache, than short-circuit
			# the resolving code.
			eval local CACHE=\"\$_shoopcache_link_$TRUEMETH\"
			if [ "$CACHE" ]; then
				eval GETMETH=\"\$$CACHE\"
			fi
		fi

		resolve() {
			local GETTYPE
			eval set -- $PARENTS
			# 1st stage resolver.  Look at the immediate parents.
			while [ $# -gt 0 ]; do
				CLASS=$1
				eval GETTYPE=\"\$_shooptype_${CLASS}_$METH\"
				if [ "$GETTYPE" ]; then
					return
				fi
				# Save the parents of the current parents, for use in the
				# 2nd stage resolver.  Yes, this slows the 1st stage down,
				# but barely.  However, it greatly speeds up the 2nd stage,
				# which is where most of the time will be spent.  This
				# gave an 8% speedup in the 2nd stage, and only noise in
				# the first.
				NEWPARENTS="${NEWPARENTS:+ $NEWPARENTS}$(eval eval "\$_shoop_${CLASS}_parent")"
				shift
			done
			# 1st stage found no match, so resolve the inheritance tree,
			# starting at the second level, and loop over untested super
			# classes.
			set -- $NEWPARENTS
			while [ $# -gt 0 ];do
				CLASS=$1
				eval GETMETH=\"\$_shoop_${CLASS}_$METH\"
				if [ "$GETMETH" ]; then
					# Save a reference to the resolved object in the cache for the
					# true object.
					if [ -z "$_shoopnocache_" ]; then
						eval _shoopcache_link_${THIS}_$METH=_shoop_${CLASS}_$METH\
						     _shoopcache_=\"\$_shoopcache_\
							  _shoopcache_method_$METH _shoopcache_link_${THIS}_$METH \"\
						     _shoopcache_method_$METH=\"\$_shoopcache_method_$METH\
							  _shoopcache_link_${THIS}_$METH\"\
						     _shoopcache_linkmethod_${CLASS}_$METH=\"\$_shoopcache_linkmethod_${CLASS}_$METH\
							  _shoopcache_link_${THIS}_$METH\"
					fi
					return
				fi
				shift
				set -- $(eval eval "\$_shoop_${CLASS}_parent") "$@"
			done
			return 1
		}
		if ! resolve; then
			echo "\"$METH\" is undefined for $TRYOBJ." >&2
			return 1
		fi
	fi
	if [ "$CLASS" ]; then
		local _shoopclassstack_new="$_shoopclassstack_old $CLASS"
		local _shoopclassstack_old=$_shoopclassstack_new
		eval GETMETH=\"\$_shoop_${CLASS}_$METH\"
	fi
	if [ "$GETMETH" ]; then
		local oIFS="$IFS"
		IFS=""
		eval "IFS='$oIFS'; $GETMETH"
		return
	fi
}
# _shoopcache_link_DESCENDENT_counter=_shoop_OBJECT_counter
# _shoopcache_= _shoopcache_method_new _shoopcache_link_GRANDCHILD_new  _shoopcache_method_counter _shoopcache_link_DESCENDENT_counter 
# _shoopcache_method_counter= _shoopcache_link_DESCENDENT_counter
# _shoopcache_linkmethod_OBJECT_counter= _shoopcache_link_DESCENDENT_counter

_shoopcacheclear_='
	if eval [ \"\$_shoopcache_method_$METH\" ]; then
		# Ok, the current METH is already in someone''s cache.
		# Find out if it is THIS object that is referenced.
		if eval [ -z \"\$_shoopcache_linkmethod_$TRUEMETH\" ]; then
			# Someone is referencing \$METH, and it is not TRUEMETH, so
			# that means we have to erase all references for \$METH.
			#
			# TODO: Only erase if $TRUE was in the parent path of
			# \$_shoopcache_method_\$METH
			eval unset _shoopcache_method_$METH\
				 \$_shoopcache_method_$METH\
				 _shoopcache_linkmethod_$TRUEMETH\
				 \$_shoopcache_linkmethod_$TRUEMETH || true;
		fi;
	fi
'
# Temporarily turn on introspection, so the base object has everything 
# recorded about it as it is being created.
_shoop_introspect=1

# Create a method to create a new object.

# We clear the whole cache, whenever a new object is created.  This
# is sub-optimal, as it should really only dump cache chains that
# have traversed this object.
#
# The reason for this, is because we use lazy resolving.  You can
# set your parents to non-existant objects, and define those objects
# at a later time.  However, if the newer object contains a method
# that has already been resolved(and cached) by the first object,
# this will lead to a cache inconsistency.

_shoop . OBJECT OBJECT new :p '
	eval "$1 () { local cmd=\"\$1\"; shift; _shoop \$cmd $1 $1 \"\$@\"; };"
	if [ $THIS != $1 ]; then
		_shoop . $1 $1 parent = $THIS >/dev/null
	fi
	eval unset _shoopcache_ \$_shoopcache_ || true
'
# Create the base object via the method already defined on it.
_shoop . OBJECT OBJECT new OBJECT

# Define the parent variable
OBJECT . parent = ""

# This method handles calling an overridden method of your parent.
OBJECT . super :p '
	local __last_class=$(set -- $_shoopclassstack_old;eval echo \$\{$(($# - 1))\})
	eval local "__super_savetype=\"\$_shooptype_${__last_class}_$LASTMETH\" _shooptype_${__last_class}_$LASTMETH="
	_shoop . $THIS $THIS "$LASTMETH" "$@"
	eval _shooptype_${TRYOBJ}_$__last_meth=$__super_savetype
'

# Now if you want introspection, you have to turn it back on.
unset _shoop_introspect
