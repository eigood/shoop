OBJECT . new LIST

## Variables:
##>4
##:size
## This holds the number of elements in this list.  As elements are added
## and removed, the value of this variable goes up and down to match.
##:_count
## The next internal pointer to use when adding an element.  This is
## always incremented.
##:_order
## The element number to physical slot mapping is maintained in this
## variable.
##<

LIST . size =q 0
LIST . _count =q 0
LIST . _order =q ''

LIST . add :p '
	local count=$(($($THIS . _count) + 1)) size=$(($($THIS . size) + 1)) order=$($THIS . _order)
	$THIS . _count =q $count
	$THIS . size =q $size
	$THIS . _order =q "${order:+$order }$count"
	$THIS . set $size "$@"
'
LIST . increase_size :p '
	local count=$(($($THIS . _count) + 1)) neworder order=$($THIS . _order)
	local i=$count
	count=$(($count + $1))
	while [ $i -lt $count ]; do
		neworder="${neworder:+$neworder }$i"
		$THIS . _$i =q ""
		i=$(($i + 1))
	done
	$THIS . _count =q $count
	$THIS . size =q $(($($THIS . size) + $1))
	$THIS . _order =q "${order:+$order }$neworder"
'
LIST . insert :p '
	$THIS . insertat 1 "$@"
'
LIST . insertat :p '
	local pos="$1"; shift
	local count=$(($($THIS . _count) + 1)) order=$($THIS . _order)
	$THIS . _count =q $count
	$THIS . size =q $(($($THIS . size) + 1))
	$THIS . _order =q "$count${order:+ $order}"
	$THIS . set $pos "$@"
'
LIST . get :p '
	local pos=$1; shift
	set -- $($THIS . _order)
	eval $THIS . _\$$pos
'
LIST . set :p '
	local pos=$1 args; shift
	eval "args=\"$@\""
	set -- $($THIS . _order)
	eval $THIS . _\$$pos = \"\$args\"
'
LIST . delete :p '
	local ret left pos=$1 order="$($THIS . _order)"; shift
	$THIS . get $pos
	$THIS . drop $pos
	set -- $order
	eval $THIS d _\$$pos
	shift $(($pos - 1))
	left="${order%%$@}"
	shift
	$THIS . _order =q "${left:+$left }$@"
	$THIS . size =q $(($($THIS . size) - 1))
	order="$($THIS . _order)"
	: order $order
'
LIST . drop :p '
	eval $THIS d _\$$1
'
LIST . rol :p '
	local count size=$($THIS . size) order left
	count=$((${1:-1} % $size))
	if [ $count -gt 0 ]; then
		order="$($THIS . _order)"
		set -- $order
		shift $count
		set -- "$@ ${order%% $@}"
		$THIS . _order =q "$@"
	fi
'
LIST . ror :p '
	local count size=$($THIS . size) order left
	count=$(($size - (${1:-1} % $size)))
	if [ $count -gt 0 ]; then
		order="$($THIS . _order)"
		set -- $order
		shift $count
		set -- "$@ ${order%% $@}"
		$THIS . _order =q "$@"
	fi
'
