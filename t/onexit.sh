#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh


ok "" 0 ""		OBJECT . use onexit

# setup
ok "" 0 ""		ONEXIT . new onexit
ok "" 0 0		onexit . size

# addition
ok "" 0 ""		onexit . add echo 1
ok "" 0 1		onexit . size
ok "" 0 ""		onexit . add echo 2
ok "" 0 2		onexit . size

# fetching
ok "" 0 "echo 2"	onexit . get 2
ok "" 0 "echo 1"	onexit . get 1

# insertion
ok "" 0 ""		onexit . insert echo 3
ok "" 0 3		onexit . size
ok "" 0 "echo 3"	onexit . get 1
ok "" 0 "echo 2"	onexit . get 3

# pushing and popping
ok "" 0 ""		onexit . push echo 4
ok "" 0 4		onexit . size
ok "" 0 ""		onexit . push echo 5
ok "" 0 5		onexit . size
ok "" 0 "echo 5"	onexit . pop
ok "" 0 4		onexit . size
ok "" 0 "echo 4"	onexit . get 4

# running
ok "" 0 "3 1 2 4 "	onexit . run
ok "" 0 "3 1 2 4 "	ONEXIT . run

# multiple onexit objects
ok "" 0 ""		ONEXIT . new onexit2
ok "" 0 ""		onexit2 . add echo a
ok "" 0 "a "		onexit2 . run

# multiple onexit objects
ok "" 0 ""		ONEXIT . inew onexit3
ok "" 0 ""		onexit3 . add echo Z
ok "" 0 "Z "		onexit3 . run

# global runnings
ok "" 0 "Z 3 1 2 4 a "	ONEXIT . run

# at exit
#ok "" 0 "Z3124a"	exit

tests 29
