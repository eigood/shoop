#!/bin/sh -e
#
# Finalization module for shoop. Expands the BASE class with a finalize
# method. The method takes the names of a list of properites and/or methods
# that should become final. (Though they may be overridden in a child class.)

BASE . finalize : '
	local item;
	for item in $@; do
		eval readonly _shoop_${THIS}_${item};
	done
'
