OBJECT . use list
LIST . new STACK

STACK . push :p '
	$THIS . add "$@"
'
STACK . pop :p '
	local count=${1:-1} size=$($THIS . size) targetsize
	targetsize=$(($size - $count))
	while [ $size -gt $targetsize ]; do
		$THIS . delete $size
		size=$(($size - 1))
	done
	: THIS=$THIS $($THIS . _order)
'
STACK . peek :p '
	$THIS . get $($THIS . size)
'
