#!/bin/sh
#                                                                               
# Use module for shoop. Expands the OBJECT class with a method named use, 
# that can import shoop modules, and prevents multiple definitions from
# happenning.  It searches in the path defined in $THIS . usepath.
# 
# Example: OBJECT . use serialize destroy
#                                                                               
# GPL copyright 2000 by Adam Heath <doogie@debian.org>
OBJECT . usepath = $SHOOPPATH:. > /dev/null

IFS=" " OBJECT . use : '
	local A B;
	for A in "$@"; do
		if eval [ -z \"\$_shoopuse_$A\" ]; then
			for B in $(IFS=":" $THIS . usepath);do
				if [ -e $B/$A.sh ]; then
					. $B/$A.sh;
					_shoopuse_="$_shoopuse_ $A";
					eval "_shoopuse_$A=1";
					break;
				fi;
			done;
		fi;
	done
'
_shoopuse_use=1
