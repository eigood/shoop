#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/share/shoop/shoop.sh}

# Setting/getting variables.
ok "" 0 ""	OBJECT . count :p 'echo OBJECT-$THIS'
ok "" 0 ""	OBJECT . new ONE
ok "" 0 ""	ONE . count :p 'echo ONE-$THIS;$THIS . super'
ok "" 0 ""	ONE . new TWO
ok "" 0 ""	TWO . count :p 'echo TWO-$THIS;$THIS . super'

ok "" 0 "OBJECT-OBJECT
"		OBJECT . count
ok "" 0 "ONE-ONE
OBJECT-ONE
"	ONE . count
ok "" 0 "TWO-TWO
ONE-TWO
OBJECT-TWO
"	TWO . count

tests 8

