#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

# Setting/getting variables.
ok "" 0 1	OBJECT . counter = 1
ok "" 0 2	OBJECT . counter = 2
ok "" 0 hi	OBJECT . moo = hi
ok "" 0 2	OBJECT . counter
ok "" 0 hi	OBJECT . moo

# Methods.
ok "" 0 ""	OBJECT . count : '$THIS . counter = $(expr $($THIS . counter) + 1)'
ok "" 0 3	OBJECT . count
ok "" 0 4	OBJECT . count

# Multi-level variable and method inheritance.
ok "" 0 ""	OBJECT . new CHILD
ok "" 0 4	CHILD . counter
ok "" 0 ""	CHILD . new GRANDCHILD
ok "" 0 4	GRANDCHILD . counter
ok "" 0 ""	GRANDCHILD . new DESCENDENT
ok "" 0 4	DESCENDENT . counter
ok "" 0 5	OBJECT . count
ok "" 0 6	GRANDCHILD . count

# Inherited variable override.
ok "" 0 6	CHILD . count
ok "" 0 6	DESCENDENT . counter
ok "" 0 7	CHILD . count
ok "" 0 6	OBJECT . count
ok "" 0 6	DESCENDENT . counter
ok "" 0 7	DESCENDENT . count

# calling super
ok "" 0 ""			CHILD . supertest : 'echo -n CHILD'
ok "" 0 ""			GRANDCHILD . supertest : 'echo -n GRAND; $THIS . super'
ok "" 0 "GRANDCHILD"		GRANDCHILD . supertest
ok "" 0 ""			DESCENDENT . supertest : 'echo -n DESCENDENT; $THIS . super'
ok "" 0 "DESCENDENTGRANDCHILD"	DESCENDENT . supertest

# Multiple inheritance.
ok "a" 0 "" OBJECT . new MOTHER
ok "b" 0 "" OBJECT . new FATHER
ok "c" 0 "" OBJECT . new SOMEGUY
ok "d" 0 "" MOTHER . new KID
ok "e" 0 "FATHER MOTHER" KID . parent = FATHER MOTHER
ok "f" 0 blue	MOTHER . eyes = blue
ok "g" 0 blue	KID . eyes
# Inherit from first in list by preference.
ok "" 0 brown	FATHER . eyes = brown
ok "" 0 brown	KID . eyes
ok "" 0 "SOMEGUY MOTHER" KID . parent = SOMEGUY MOTHER
ok "" 0 black	SOMEGUY . eyes = black
ok "" 0 black	KID . eyes
# TODO: What if the parent is not an object?
#ok "" '?' '??'	KID . parent = NOSUCHOBJECT
#ok "" 0 black	KID . eyes
# Inheritance loops should not be allowed.
#ok "" 1 ""		KID . parent = KID
# even spanning multiple parents
#ok "" 0 ""		OBJECT . new PARENT
#ok "" 0 ""		PARENT . new SON
#ok "" 0 "SON"	PARENT . parent = SON
#ok "" 1 ""		SON . count

tests 39
