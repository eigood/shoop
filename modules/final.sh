#!/bin/sh -e
#
# Finalization module for shoop. Expands the OBJECT class with a finalize
# method. The method takes the names of a list of properites and/or methods
# that should become final. (Though they may be overridden in a child class.)
#
# LGPL copyright 2000 by Adam Heath <doogie@debian.org>

## Passing a list of methods and/or variables to this method will finalize
## each item.  It does this thru the use of the shell builtin 'readonly.'
## Once this is done, there is no way to 'destroy' this method, nor is
## there any way to change the value.
## 
## This also sets the item to protected in shoop speak, so that _shoop can
## detect the readonlyness of the item, and issue a warning.

IFS=" " OBJECT . final :p '
	local item varmeth
	for item in $@; do
		if eval  [ -z \"\$_shoopfinal_${THIS}_$item\" ]; then
			eval "readonly _shoop_${THIS}_$item
			      _shoopfinal_${THIS}_$item=1
			      _shoopfinal_$THIS=\"\$_shoopfinal_$THIS $item\""
		fi
		if eval [ \"\$_shooptype_${THIS}_$item\" = variable ]; then
			$THIS . $item =p
		else
			$THIS . $item :p
		fi
	done
	return
'
