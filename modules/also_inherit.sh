#!/bin/sh -e
#
# Multiple inheritance module for shoop.  Walks the object tree, looking for
# loops(A from B, B from C, C from A type inheritance), and removes any
# parent from the assignment that has a loop.
#
# This only adds new parents.  It doesn't replace.
#
# For example: FOO . also_inherit BAR BAZ
#
# GPL copyright 2000 by Adam Heath <doogie@debian.org>

IFS=" " OBJECT . also_inherit : '
	eval local a curp=$1 newparents="" parents="" retval=0 lastp _seen_child_$THIS=1 p
	eval set -- $(eval eval "\$_shoop_${THIS}_parent") "$@"

	while [ $# -gt 0 ];do
		if [ "$1" = "}" ]; then
			while [ "$1" = "}" ]; do
				: Pop the stack
				eval unset _seen_unset_$2 \$_seen_unset_$2
				lastp=$2
				shift 2
			done
			curp=$1
			if [ -z \"\$bad_parent_$lastp\" ] ; then
				newparents="$newparents $lastp"
			fi
		fi
		# We have processed this node, so skip it.
		if eval [ \"\$visited_$1\" ]; then
			shift
		elif eval [ \"\$_seen_child_$1\" ]; then
			# Parent Loop : $THIS $curp
			local bad_parent_$curp=1 retval=1 visited_$1=1; shift
			echo "Parent loop detected. $THIS:$curp"
		else
			eval local visited_$1=1 _seen_unset_$curp=\"\$_seen_unset_$curp _seen_child_$1\" _seen_child_$1=1 parents=$(eval eval "\$_shoop_${1}_parent") p=$1; shift
			if [ "$parents" ];then
				set -- $parents "}" "$p" "$@"
			fi
		fi;
	done
	# newparents is $newparents
	$THIS . parents .= $newparents
	return $retval
'
