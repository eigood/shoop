OBJECT . new OBJECT_REF

OBJECT_REF . new :p '
	local CLASS=$1; shift
	if [ $# -gt 1 ]; then
		local OBJNAME
		OBJECT_REF . _ref OBJNAME
		eval "$@ :p ''$OBJNAME \\\"\\\$@\\\"''"
	else
		OBJECT_REF . _ref $1
		eval local OBJNAME=\$$1
	fi
	$THIS . super $OBJNAME
	$OBJNAME . parent .=q "$CLASS"
'
OBJECT_REF . _ref :p '
	eval $1=_$(($($THIS . __ref 2>/dev/null) + 1))
	eval "$THIS . __ref =q \${$1#_}"
'
