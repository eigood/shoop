#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ./shoop.sh

# Setting/getting variables.
ok 1	OBJECT . counter = 1
ok 2	OBJECT . counter = 2
ok hi	OBJECT . moo = hi
ok 2	OBJECT . counter
ok hi	OBJECT . moo

# Methods.
ok ""	OBJECT . count : '$THIS . counter = $(expr $($THIS . counter) + 1)'

tests 6
