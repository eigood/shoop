#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

ok "" 0 ""		OBJECT . use shoop_command

ok "" 0 ""		SHOOP . command . register p 'echo -n "TRUEOBJ=$TRUEOBJ TRYOBJ=$TRYOBJ METH=$METH REST='"'"'$@'"'"'";return'

ok "" 0 "TRUEOBJ=SHOOP TRYOBJ=SHOOP METH=command REST='. register'"		SHOOP p command . register

tests 3
