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
## 
## There is also '_USE . findmodule <path> <module>' convience method,
## which looks thru the path trying to find <module>.sh.

OBJECT . usepath = $SHOOPPATH:. > /dev/null

OBJECT . new _USE

_USE . findmodule :p '
	local oIFS="$IFS" IFS=:
	local usepath="$1"; shift
	for B in $usepath;do
		IFS="$oIFS"
		if [ -e $B/$1.sh ]; then
			echo $B/$1.sh
			break
		fi
	done
'
IFS=" " OBJECT . use :p '
	local A B usepath="$($THIS . usepath)" module
	for A in "$@"; do
		if [ -z "$(_USE . _used_$A 2>/dev/null)" ]; then
			module=$(_USE . findmodule "$usepath" $A)
			if [ "$module" ]; then
				. $module
				_USE . _used_ .=q " $A"
				_USE . _used_$A =q 1
			fi
		fi
	done
	return
'
_shoopuse_use=1
