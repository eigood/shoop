#!/bin/sh
. ./shoop.sh
. ./introspect.sh
. ./serialize.sh
. ./final.sh

echo some counters:
OBJECT . counter = 10
echo
OBJECT . count : '$THIS . counter = $(expr $($THIS . counter) + 1)'
OBJECT . test = 20
OBJECT . finalize test
echo
OBJECT . count
echo
OBJECT . new FOO
OBJECT . new BAR
BAR . parent = A B C D FOO >/dev/null
BAR . test
echo
FOO . count : '$THIS . counter = $(expr $($THIS . counter) \* 2 + $($THIS . super count))'
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
echo introspecting FOO
FOO . introspect resolve
echo serializing OBJECT
OBJECT . serialize
echo serializing FOO
FOO . serialize
