#!/bin/sh
IFS=" " OBJECT . use : '
	local A;
	for A in "$@"; do
		if eval [ -z \"\$_shoopuse_$A\" ]; then
			. $A.sh;
			_shoopuse_="$_shoopuse_ $A";
			eval "_shoopuse_$A=1";
		fi;
	done
'
