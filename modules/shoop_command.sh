OBJECT . use shoop ref alist

OBJECT_REF . new OBJECT SHOOP . command
OBJECT_REF . new ALIST SHOOP . command . list 

SHOOP . command . register :p '
	$THIS . list . add "$@"
	local ref=$($THIS . list . get $($THIS . list . size))
	local key="$($ref . getkey)" value="$($ref . getvalue)"
	: key=$key value=$value
	_shoopcommand_middle_="${_shoopcommand_middle_:+$_shoopcommand_middle_
}
$key)	$value;;"
'
