#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}


ok "" 0 ' 	
'		eval 'printf "%s" "$IFS"'
tests 1
