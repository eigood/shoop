OBJECT . use stack
STACK . new ONEXIT

## This module allows for running of several commands when the shell
## script exits.  It inherits from stack.sh, so the normal add/insert/
## push/pop commands are available.  Note, that add/insert do not
## return what was passed to them.  pop does, however.
## 
## When the end of the script is reached, the code that is run iterates
## over all registered ONEXIT objects.  These objects are automatically
## registred with the system, when you instantiate(new) them.  If you
## use the 'inew' method, however, it inserts at the end of the list
## the new object, instead of placing it at the end(the default).
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
	$OBJNAME . _order =q ""
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
