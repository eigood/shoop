#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}

# setup
ok "" 0 1	OBJECT . counter = 1
ok "" 0 ""	OBJECT . incr :p '$THIS . counter = $(($($THIS . counter) + 1))'
ok "" 0 ""	OBJECT . new object

# sanity check
ok "" 0 1	OBJECT . counter
ok "" 0 2	OBJECT . incr
ok "" 0 2	OBJECT . counter
ok "" 0 3	OBJECT . incr
ok "" 0 3	OBJECT . counter

# creating the reference
ok "" 0 ""	OBJECT . new object . o

# getting/setting
ok "" 0 "3"	object . o . counter
ok "" 0 "10"	object . o . counter = 10
ok "" 0 "10"	object . o . counter

# methods
ok "" 0 ""	object . o . decr :p '$THIS . counter = $(($($THIS . counter) - 1))'
ok "" 0 "11"	object . o . incr
ok "" 0 "11"	object . o . counter
ok "" 0 "10"	object . o . decr
ok "" 0 "10"	object . o . counter

# sanity check
ok "" 0 3	OBJECT . counter
ok "" 0 3	object . counter
ok "" 0 10	object . o . counter

tests 20
