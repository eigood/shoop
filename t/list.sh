#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh


ok "" 0 ""		OBJECT . use list

# setup
ok "" 0 ""		LIST . new list
ok "" 0 0		list . size

# addition
ok "" 0 "first"		list . add "first"
ok "" 0 1		list . size
ok "" 0 "second"	list . add "second"
ok "" 0 2		list . size

# insertion
ok "" 0 "third"		list . insert "third"
ok "" 0 3		list . size

# fetching
ok "" 0 "first"		list . get 2
ok "" 0 "second"	list . get 3

# setting
ok "" 0 "FIRST"		list . set 2 "FIRST"
ok "" 0 "FIRST"		list . get 2

# deletion
ok "" 0 "FIRST"		list . delete 2
ok "" 0 2		list . size
ok "" 0 "second"	list . get 2
ok "" 0 "SECOND"	list . add "SECOND"
ok "" 0 3		list . size

# sanity check
ok "" 0 "third"		list . get 1
ok "" 0 "second"	list . get 2
ok "" 0 "SECOND"	list . get 3

# rotation
ok "" 0 ""		list . ror 1
ok "" 0 3		list . size
ok "" 0 "SECOND"	list . get 1
ok "" 0 "third"		list . get 2
ok "" 0 "second"	list . get 3
ok "" 0 ""		list . rol 2
ok "" 0 3		list . size
ok "" 0 "second"	list . get 1
ok "" 0 "SECOND"	list . get 2
ok "" 0 "third"		list . get 3

tests 31
