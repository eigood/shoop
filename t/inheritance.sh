#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ./shoop.sh

# Setting/getting variables.
ok 0 1	OBJECT . counter = 1
ok 0 2	OBJECT . counter = 2
ok 0 hi	OBJECT . moo = hi
ok 0 2	OBJECT . counter
ok 0 hi	OBJECT . moo

# Methods.
ok 0 ""	OBJECT . count : '$THIS . counter = $(expr $($THIS . counter) + 1)'
ok 0 3	OBJECT . count

tests 7
