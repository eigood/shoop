OBJECT . use stack
STACK . new ONEXIT

ONEXIT . add :p '
	$THIS . super "$@" > /dev/null
'
ONEXIT . insert :p '
	$THIS . super "$@" > /dev/null
'
ONEXIT . new :p '
	local OBJNAME=$1
	$THIS . super "$@"
	$OBJNAME . size =q 0
	$OBJNAME . _count =q 0
	$OBJNAME . _order =q ''
	ONEXIT . add "$OBJNAME . run"
'
ONEXIT . inew :p '
	local OBJNAME=$1
	$THIS . new "$@"
	ONEXIT . ror
'
ONEXIT . run :p '
	local count=1 size=$($THIS . size)
	while [ $count -le $size ]; do
		eval $($THIS . get $count)
		count=$(($count + 1))
	done
'
