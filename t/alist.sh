#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

ok "" 0 ""		OBJECT . use alist ref

# setup
ok "" 0 ""		ALIST . new alist
ok "" 0 0		alist . size

# addition
ok "" 0 ""		alist . add "first" "1 value"
ok "" 0 1		alist . size
ok "" 0 ""		alist . add "second" "2 value"
ok "" 0 2		alist . size

# fetching with helper methods
ok "" 0 "first"		alist . getkey 1
ok "" 0 "second"	alist . getkey 2
ok "" 0 "1 value"	alist . getvalue 1
ok "" 0 "2 value"	alist . getvalue 2

# fetching thru a reference
ok "" 0 "first"		eval '$(alist . get 1)' . getkey
ok "" 0 "2 value"	eval '$(alist . get 2)' . getvalue

# insertion
ok "" 0 ""		alist . insert "third" "3 value"
ok "" 0 3		alist . size

# fetching
ok "" 0 "third"		alist . getkey 1
ok "" 0 "first"		alist . getkey 2
ok "" 0 "second"	alist . getkey 3
ok "" 0 "1 value"	alist . getvalue 2
ok "" 0 "2 value"	alist . getvalue 3

ok "" 0 "third"		eval '$(alist . get 1)' . getkey
ok "" 0 "1 value"	eval '$(alist . get 2)' . getvalue

# setting
ok "" 0 "FIRST"		alist . setkey 2 "FIRST"
ok "" 0 "FIRST value"	alist . setvalue 2 "FIRST value"
ok "" 0 "FIRST"		alist . getkey 2
ok "" 0 "FIRST value"	alist . getvalue 2

# deletion
ok "A" 0 ""		alist . delete 2
ok "" 0 2		alist . size
ok "" 0 "second"	alist . getkey 2
ok "" 0 ""		alist . add "SECOND" "SECOND value"
ok "" 0 3		alist . size

tests 31
