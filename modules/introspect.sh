#!/bin/sh -e
#
# Introspect module for shoop. Expands the BASE class with an introspect
# method, that can list all methods and variables that are defined on a class.
#
# Smell the Java. GPL copyright 2000 by Adam Heath <adam.heath@usa.net>

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
