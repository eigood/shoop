#!/bin/sh -e
#
# Finalization module for shoop. Expands the OBJECT class with a finalize
# method. The method takes the names of a list of properites and/or methods
# that should become final. (Though they may be overridden in a child class.)

OBJECT . finalize : '
	local item;
	for item in $@; do
		eval readonly _shoop_${THIS}_${item};
	done
'
