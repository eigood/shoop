#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

# setup
ok "" 0 ""	OBJECT . use serialize
ok "" 0 ""	OBJECT . new object
ok "" 0 "1"	object . foo = 1
ok "" 0 ""	object . bar : '$THIS . foo'

#fixup sed "s/'/''/g"
ok "" 0 "OBJECT . new object;
object . foo =q 1;
object . bar : '\$THIS . foo';"	object . serialize
tests 5
