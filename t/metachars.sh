#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}

ok "" 0 'a'	OBJECT . var = a
ok "" 0 'a'	OBJECT . var
ok "" 0 ''	OBJECT . method : "echo -n a"
ok "" 0 'a'	OBJECT . method

stuff="a'b'c'"
stuff_fixed="a'\''b'\''c'\''"
ok "_shoop_tr" 0 "$stuff_fixed"	eval '_shoop_tr "'\''" "'\''\\'\'\''" "$stuff"; echo -n "$out"'

stuff="aaaaa'bbbbbÅccccc"
stuff_fixed="aaaaa'\''bbbbbÅccccc"
ok "_shoop_tr" 0 "$stuff_fixed"	eval '_shoop_tr "'\''" "'\''\\'\'\''" "$stuff"; echo -n "$out"'

c=8
for meta in \` \~ \! \@ \# \$ \% \^ \& \* \( \) \{ \} \[ \] \| \\ \; \' \" \< \> \? ' '; do
	# Let's make sure the testing framework can handle the metacharacters
	ok "$meta" 0 "$meta"		echo -n "$meta"

	# Now let's test shoop
	ok "set-$meta" 0 "a${meta}a"	OBJECT . var = "a${meta}a"
	ok "get-$meta" 0 "a${meta}a"	OBJECT . var

	_shoop_tr "'" "'\\''" "$meta"
	ok "method-$meta" 0 ""		OBJECT . method : "echo -n 'a${out}a'"
	ok "call-$meta" 0 "a${meta}a"	OBJECT . method

	c=$(($c+5))
	allmeta="$allmeta$meta"
done

# All metachars at once
ok "set-all" 0 "$allmeta$allmeta$allmeta"	OBJECT . var = "$allmeta$allmeta$allmeta"
ok "get-all" 0 "$allmeta$allmeta$allmeta"	OBJECT . var

tests $c
