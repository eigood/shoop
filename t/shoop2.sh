#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}
. ${SHOOP2SH:-/usr/share/shoop/shoop2.sh}
#. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

SHOOP abstract class TEST
	SHOOP abstract method _print
	SHOOP public method print '
		$THIS . _print "$@"
	'
	SHOOP public variable var = 1
SHOOP end
SHOOP public class REAL : TEST
	SHOOP public method _print '
		echo "real:$@"
	'
SHOOP end


ok "" 0 ""		SHOOP new t : REAL
ok "" 0 "1"		t . var
ok "" 0 "real:1"	t . print $(t . var)

tests 3
