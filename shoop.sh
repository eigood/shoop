#!/bin/sh -e
# OOP in shell. GPL copyright 2000 by Joey Hess <joey@kitenet.net>

_shoop () {
	local TRUEOBJ=$1
	local TRYOBJ=$2
	local METH=$3
	shift 3

	if [ "$1" = = -o "$1" = : ]; then
		if eval [ "\$_shooptype_${TRYOBJ}_$METH" ]; then
			eval "_shoopdefines_$TRUEOBJ=\"$_shoopdefines_$TRUEOBJ $METH\""
		fi
		if [ "$1" = = ]; then
			shift
			eval "_shooptype_${TRUEOBJ}_$METH=variable"
			eval "_shoop_${TRUEOBJ}_$METH () { echo $@; }"
#			eval "_shoop_${TRUEOBJ}_$METH=$@"
			echo $@
		else
			shift
			eval "_shooptype_${TRUEOBJ}_$METH=method"
			eval "_shoop_${TRUEOBJ}_$METH () { $@
}"
		fi
# Alternate, variable method. Benchmark before turning on. (See line above, too.)
#	elif eval [ \"\$_shooptype_${TRYOBJ}_$METH\" = variable ]; then
#		eval echo \$_shoop_${TRYOBJ}_$METH
	elif eval [ "\$_shooptype_${TRYOBJ}_$METH" ]; then
		eval _shoop_${TRYOBJ}_$METH $TRUEOBJ \"\$@\";
	else
		eval local PARENTS=\$_shoopparent_$TRYOBJ
		if [ "$PARENTS" ]; then
			local P
			for P in $PARENTS;do
				if _shoop $TRUEOBJ $P $METH $@ 2>/dev/null; then
					return 0
				fi
			done
		fi
		echo "\"$METH\" is undefined." >&2
		return 1
	fi
}

# Create a base object class. All other objects will inherit from this.

# Create a method to create a new object.
_shoop BASE BASE new : '
	local PARENT=$1
	local OBJNAME=$2
	
	eval "$OBJNAME () { shift; _shoop $OBJNAME $OBJNAME \$@; }"
	if [ "$PARENT" ]; then
		eval "_shoopparent_$OBJNAME=$PARENT"
	fi
'
# Make the base object.
_shoop_BASE_new '' BASE
BASE . parent : '
local OBJNAME=$1;
shift;
eval _shoopparent_$OBJNAME=\"$@\"
'
BASE . introspect : '
local OBJNAME=$1 DEFINES TYPE A DISPLAYOBJ;
shift;
if [ "$2" ];then
	DISPLAYOBJ=$2;
else
	DISPLAYOBJ=$OBJNAME;
fi;
eval DEFINES=\$_shoopdefines_$OBJNAME;
for A in $DEFINES; do
	if ! echo $_shoop_introspect_seen | tr " " "\n" | grep -q "^$A$";then
		eval TYPE=\$_shooptype_${OBJNAME}_$A;
		echo "$DISPLAYOBJ: $A is $TYPE";
		_shoop_introspect_seen="$_shoop_introspect_seen $A";
	fi
done;
if [ "$1" = resolve ];then
	eval local PARENT=\$_shoopparent_$OBJNAME;
	for P in $PARENT;do
		$P . introspect resolve $DISPLAYOBJ;
	done
fi;
for A in $DEFINES; do
	_shoop_introspect_seen=$(echo $_shoop_introspect_seen | tr " " "\n" | grep -v "^$A$");
done
'
