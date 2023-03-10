OBJECT . use stack
STACK . new SIGNAL

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
SIGNAL . add :p '
	$THIS . super "$@" > /dev/null
'
SIGNAL . insert :p '
	$THIS . super "$@" > /dev/null
'
SIGNAL . new :p '
	local signal=$1 OBJNAME=$2; shift 1

	$THIS . super "$@"
	$OBJNAME . size =q 0
	$OBJNAME . _count =q 0
	$OBJNAME . _order =q ""
	SIGNAL . add "$OBJNAME . run"
	local ref=$(OBJECT . _ref)
	
SIGNAL . register_signal 
'
SIGNAL . 

SIGNAL . 
SIGNAL . inew :p '
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
