OBJECT . new LIST

LIST . size =q 0
LIST . _count =q 0
LIST . _order =q ''

LIST . add :p '
	local count=$(($($THIS . _count) + 1)) size=$(($($THIS . size) + 1))
	$THIS . _count =q $count
	$THIS . size =q $size
	$THIS . _order =q "$($THIS . _order) $count"
	$THIS . set $size "$@"
'
LIST . insert :p '
	$THIS . insertat 1 "$@"
'
LIST . insertat :p '
	local pos="$1"; shift
	local count=$(($($THIS . _count) + 1))
	$THIS . _count =q $count
	$THIS . size =q $(($($THIS . size) + 1))
	$THIS . _order =q "$count $($THIS . _order)"
	$THIS . set $pos "$@"
'
LIST . get :p '
	local pos=$1; shift
	set -- $($THIS . _order)
	eval $THIS . _\$$pos
'
LIST . set :p '
	local pos=$1; shift
	local args="$@"
	set -- $($THIS . _order)
	eval $THIS . _\$$pos = \"\$args\"
'
LIST . delete :p '
	local ret left pos=$1 order="$($THIS . _order)"; shift
	$THIS . get $pos
	eval $THIS d _\$$pos
	set -- $order
	shift $(($pos - 1))
	left="${order%%$@}"
	shift
	$THIS . _order =q "$left $@"
	$THIS . size =q $(($($THIS . size) - 1))
	order="$($THIS . _order)"
	: order $order
'
