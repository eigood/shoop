#!/bin/sh -e
#
# Finalization module for shoop. Expands the OBJECT class with a finalize
# method. The method takes the names of a list of properites and/or methods
# that should become final. (Though they may be overridden in a child class.)

IFS=" " OBJECT . finalize : '
	local item;
	for item in $@; do
		if eval  [ -z \"\$_shoopfinal_${THIS}_$item\" ]; then
			eval "readonly _shoop_${THIS}_$item;
			      _shoopfinal_${THIS}_$item=1;
			      _shoopfinal_$THIS=\"\$_shoopfinal_$THIS $item\"";
		fi
	done;
	return
'
