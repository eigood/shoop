OBJECT . use list destroy
LIST . new ALIST

OBJECT . new ALIST_ENTRY
ALIST_ENTRY . getkey = ""
ALIST_ENTRY . getvalue = ""

ALIST . newpair :p '
	OBJECT . _ref $1
	eval local ref=\$$1;
	shift
	ALIST_ENTRY . new $ref
	$ref . getkey =q "$1"
	$ref . getvalue =q "$2"
'

ALIST . set :p '
        local pos=$1 ref; shift
	$THIS . newpair ref "$1" "$2"
        set -- $($THIS . _order)
        eval $THIS . _\$$pos =q \"\$ref\"
'
ALIST . getkey :p '
	local pos="$1" ref=$($THIS . get "$1"); shift
	$ref . getkey
'
ALIST . setkey :p '
	local pos="$1" ref=$($THIS . get "$1"); shift
	$ref . getkey = "$@"
'
ALIST . getvalue :p '
	local pos="$1" ref=$($THIS . get "$1"); shift
	$ref . getvalue
'
ALIST . setvalue :p '
	local pos="$1" ref=$($THIS . get "$1"); shift
	$ref . getvalue = "$@"
'
ALIST . drop :p '
	local ref=$($THIS . get $1)
	$ref . destroy
	$THIS . super "$@" >/dev/null
'
ALIST . delete :p '
	$THIS . super "$@" > /dev/null
'
