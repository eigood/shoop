IFS=" " OBJECT . also_inherit : '
	eval local a curp=$1 newparents="" parents="" retval=0 lastp _seen_child_$THIS=1;
	eval set -- $(eval eval "\$_shoop_${THIS}_parent") "$@";

	while [ $# -gt 0 ];do
		if [ "$1" = "}" ]; then
			while [ "$1" = "}" ]; do
				: Pop the stack;
				eval unset _seen_unset_$2 \$_seen_unset_$2;
				lastp=$2 curp=$3;
				shift 2;
			done;
			if eval [ \"\$bad_parent_$lastp\" ]; then
				retval=1;
				echo "Parent loop detected. $THIS:$lastp"
			else
				newparents="$newparents $lastp"
			fi;
		fi
		# We have processed this node, so skip it.
		if eval [ \"\$visited_$1\" ]; then
			shift
			continue
		fi;
		if eval local visited_$1=1\; [ \"\$_seen_child_$1\" ]; then
			# Parent Loop : $THIS $curp;
			local bad_parent_$curp=1;
			shift;
			continue
		else
			eval local _seen_child_$1=1 _seen_unset_$curp=\"\$_seen_unset_$curp _seen_child_$1\"\;
				parents=$(eval eval "\$_shoop_$1_parent") p=$1;
			shift;
			if [ "$parents" ];then
				set -- $parents "}" "$p" "$@"
			fi
		fi;
	done;
	# newparents is $newparents;
	$THIS . parents .= $newparents
	echo "newparents is $newparents" >&2;
	return $retval
'
#		eval local visited_$1=1;
#		if eval [ \"\$_seen_child_$1\" ]; then
