#!/bin/sh
#                                                                               
# Use module for shoop. Expands the OBJECT class with a method named use, 
# use, that can import shoop modules, and prevents multiple difinitions
# from happenning.
# 
# Example: OBJECT . use serialize destroy
#                                                                               
# GPL copyright 2000 by Adam Heath <doogie@debian.org>
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
