#!/bin/sh
#                                                                               
# Use module for shoop. Expands the OBJECT class with a method named use, 
# that can import shoop modules, and prevents multiple definitions from
# happenning.  It searches in the path defined in $THIS . usepath.
# 
# Example: OBJECT . use serialize destroy
#
# LGPL copyright 2000 by Adam Heath <doogie@debian.org>

## This module defines a convience method for importing shoop modules.
## When passed the basename of a module(minus any path and .sh
## extension), it will look for the first match in $SHOOPPATH.

OBJECT . usepath = $SHOOPPATH:. > /dev/null

IFS=" " OBJECT . use :p '
	local A B usepath
	local oIFS="$IFS" IFS=:
	usepath="$($THIS . usepath)"
	IFS="$oIFS"
	for A in "$@"; do
		if eval [ -z \"\$_shoopuse_$A\" ]; then
			for B in $usepath;do
				if [ -e $B/$A.sh ]; then
					. $B/$A.sh
					_shoopuse_="$_shoopuse_ $A"
					eval "_shoopuse_$A=1"
					break
				fi
			done
		fi
	done
	return
'
_shoopuse_use=1
