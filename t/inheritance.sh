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
ok 0 6	GRANDCHILD . count

# Inherited variable override.
ok 0 6	CHILD . count
ok 0 6	DESCENDENT . counter
ok 0 7	CHILD . count
ok 0 6	OBJECT . count
ok 0 6  DESCENDENT . counter
ok 0 7	DESCENDENT . count

# Inherited method turned into a variable.
ok 0 99	CHILD . count = 99
ok 0 99	CHILD . count
ok 0 99	CHILD . count

# Inherited variable turned into method.
ok 0 ""	GRANDCHILD . count : '$THIS . counter = $(expr $($THIS . counter) + 10)'
ok 0 0	GRANDCHILD . counter = 0
ok 0 10	GRANDCHILD . count
ok 0 20	GRANDCHILD . count

# Inherited method override, with super call.
ok 0 1	DESCENDENT . counter = 1
ok 0 ""	DESCENDENT . count : \
	'$THIS . counter = $(expr $($THIS . counter) \* 2 + $($THIS . super count))'
ok 0 13	DESCENDENT . count # you do the math..

tests 32
