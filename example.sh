#!/bin/sh
. ./shoop.sh
. ./introspect.sh

echo some counters:
BASE . counter = 10
echo
BASE . count : '$_shoop_THIS . counter = $(expr $($_shoop_THIS . counter) + 1)'
BASE . test = 20
echo
BASE . count
echo
BASE . new FOO
BASE . new BAR
BAR . parent = A B C D FOO >/dev/null
BAR . test
echo
FOO . count : '$_shoop_THIS . counter = $(expr $($_shoop_THIS . counter) \* 2 + $($_shoop_THIS . super count))'
FOO . counter = 1
echo
FOO . count
echo
FOO . count
echo
FOO . count
echo
BASE . count
echo

echo BAR . introspect:
BAR . introspect
echo FOO . introspect resolve:
FOO . introspect resolve
echo BASE . introspect:
BASE . introspect
