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
ok 0 4	OBJECT . count

# Multi-level variable and inheritance.
ok 0 ""	OBJECT . new CHILD
ok 0 4	CHILD . counter
ok 0 ""	CHILD . new GRANDCHILD
ok 0 4	GRANDCHILD . counter
ok 0 ""	GRANDCHILD . new DESCENDENT
ok 0 4  DESCENDENT . counter
ok 0 5	OBJECT . count
ok 0 6	DESCENDENT . count

# Inherited variable override.
ok 0 6	CHILD . count
ok 0 6	DESCENDENT . counter
ok 0 7	CHILD . count
ok 0 6	OBJECT . count
ok 0 7  DESCENDENT . counter
ok 0 8	DESCENDENT . count

tests 22
