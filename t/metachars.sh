#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}

ok "" 0 'a'	OBJECT . var = a
ok "" 0 'a'	OBJECT . var
ok "" 0 ''	OBJECT . method : "echo a"
ok "" 0 'a'	OBJECT . method

c=4
for meta in \` \~ \! \@ \# \$ \% \^ \& \* \( \) \{ \} \[ \] \| \\ \; \' \" \< \> \? ' '; do
	# Let's make sure the testing framework can handle the metacharacters
	ok "$meta" 0 "$meta"		echo "$meta"

	# Now let's test shoop
	ok "set-$meta" 0 "a${meta}a"	OBJECT . var = "a$(echo "$meta"|sed 's/'"'/'"'\\'"''/g")a"
	ok "get-$meta" 0 "a${meta}a"	OBJECT . var

	ok "method-$meta" 0 ""		OBJECT . method : "echo 'a$(echo "$meta"|sed 's/'"'/'"'\\'"''/g")a'"
	ok "call-$meta" 0 "a${meta}a"	OBJECT . method

	c=$(($c+5))
done

tests $c
