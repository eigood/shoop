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
## Some additional methods and variables are provided thru an additional
## _USE object.  These are:
## 
##>4
##:findmodule <path> <module>;
## looks thru the path trying
## to find <module>.sh.
## 
##:recorduse
## Set to 1 to record immediate dependencies of this module.
## default = 1
## 
##:quiet
## Set to 1 to not display an error when a module isn't found.
## default = 0
## 
##:error
## Set to 1 to return an error when a module isn't found.
## default = 1
##<

OBJECT . usepath = $SHOOPPATH:. > /dev/null

OBJECT . new _USE

_USE . recorduse =q 1
_USE . quiet =q 0
_USE . error =q 1
_USE . findmodule :p '
	local oIFS="$IFS" IFS=: usepath
	usepath="$1"; shift
	for B in $usepath;do
		IFS="$oIFS"
		if [ -e $B/$1.sh ]; then
			echo $B/$1.sh
			break
		fi
	done
'
_USE . showdeps :p '
	local A usepath="$($THIS . usepath)" module
	for A in $(_USE . _record_ 2>/dev/null); do
		module=$(_USE . findmodule "$usepath" $A)
		if [ -z "$module" ]; then
			echo "$A disappeared!" 1>&2
		else
			echo "$A: $module"
		fi
	done
'
IFS=" " OBJECT . use :p '
	local A B usepath="$($THIS . usepath)" module recorduse
	recorduse="$(_USE . recorduse 2>/dev/null)"
	_USE . recorduse =q 0
	for A in "$@"; do
		if [ -z "$(_USE . _used_$A 2>/dev/null)" ]; then
			module=$(_USE . findmodule "$usepath" $A)
			if [ "$module" ]; then
				. $module
				_USE . _used_ .=q " $A"
				_USE . _used_$A =q 1
				if [ "$recorduse" ]; then
					_USE . _record_ .=q " $A"
				fi
			else
				if [ ! "$(_USE quiet)" = 1 ]; then
					echo "Could not find module $A" 1>&2
				fi
				if [ ! "$(_USE error 2>/dev/null)" = 1 ]; then
					return 1
				fi

			fi
		fi
	done
	return
'
_shoopuse_use=1
