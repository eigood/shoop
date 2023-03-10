#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh


ok "" 0 ""		OBJECT . use stack

# setup
ok "" 0 ""		STACK . new stack
ok "" 0 0		stack . size

# addition
ok "" 0 "first"		stack . push "first"
ok "" 0 1		stack . size
ok "" 0 "second"	stack . push "second"
ok "" 0 2		stack . size

# peeking
ok "" 0 "second"	stack . peek
ok "" 0 "third"		stack . push "third"
ok "" 0 "third"		stack . peek
ok "" 0 3		stack . size

# popping
ok "" 0 "third"		stack . pop
ok "" 0 "THIRD"		stack . push "THIRD"
ok "" 0 "THIRDsecond"	stack . pop 2
ok "" 0 1		stack . size

# wrapup
ok "" 0 "first"		stack . peek
ok "" 0 "first"		stack . pop
ok "" 0 0		stack . size

tests 18
