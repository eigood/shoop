OBJECT . use shoop ref alist

OBJECT_REF . new OBJECT SHOOP . command
OBJECT_REF . new ALIST SHOOP . command . list 

SHOOP . command . register :p '
	$THIS . list . add "$@"
	local key=$1 value; shift
	value="$@"
	_shoopcommand_middle_="${_shoopcommand_middle_:+$_shoopcommand_middle_
}
$key)	$value;;"
'
