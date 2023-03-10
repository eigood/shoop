#!/bin/sh
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh
OBJECT . use introspect serialize final destroy thread prettyprint
_USE . showdeps

THREAD . new TT
TT . run : '
	local a;
	for a in $(seq 1 5);do
		echo $a;
		sleep 1;
	done
'
#TT . start
#sleep 3
#TT . wait
#exit

echo some counters:
OBJECT . counter = 10
OBJECT . counter
echo
OBJECT . count : '$THIS . counter = $(expr $($THIS . counter) + 1); return'
OBJECT . test = 20
OBJECT . final test
echo
OBJECT . count
echo
OBJECT . new FOO
OBJECT . new BAR
BAR . parent = A B FOO C D OBJECT > /dev/null
BAR . test
echo
# This will produce an error.
BAR . blah
FOO . count : '$THIS . counter = $(expr $($THIS . counter) \* 2 + $($THIS . super)); return'
FOO . counter = 1
echo
FOO . count
echo
FOO . count
echo
FOO . count
echo
OBJECT . count
echo

echo introspecting BAR
BAR . introspect
OBJECT . prettyprint
echo introspecting FOO
FOO . introspect resolve

echo serializing OBJECT
#OBJECT . serialize
echo serializing FOO to temporary file
FOO . serialize > FOO.sh.tmp

echo destroying FOO
FOO . destroy
set | grep FOO
echo loading FOO
. ./FOO.sh.tmp >/dev/null
rm -f FOO.sh.tmp
FOO . count
echo
