#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}
. ${SHOOP2SH:-/usr/share/shoop/shoop2.sh}
#. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

SHOOP abstract class TEST
#	SHOOP abstract method _print
	SHOOP public method print '
		$THIS . _print "$@"
	'
	SHOOP public variable var = 1
	SHOOP public method _print '
		echo "default:$@"
	'
SHOOP end
SHOOP public class REAL : TEST
	SHOOP public method _print '
		echo "$@"
	'
SHOOP end


ok "" 0 ""	SHOOP new t : TEST
ok "" 0 ""	t . var
ok "" 0 ""	t . print $(t . var)

tests 3
